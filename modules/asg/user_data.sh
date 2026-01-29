#! /bin/bash

# 1. Install Dependencies for Amazon Linux 2023
dnf update -y
dnf install -y httpd php php-mysqlnd php-gd php-xml php-mbstring php-opcache php-pecl-redis amazon-efs-utils git mariadb105

# 2. Start Services
systemctl enable httpd
systemctl start httpd

# 3. PHP Optimization (Memory & Opcache)
if [ -f /etc/php.ini ]; then
    sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php.ini
fi

cat <<EOF > /etc/php.d/10-opcache.ini
zend_extension=opcache
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
EOF

# 4. Mount EFS Persistent
mkdir -p /var/www/html

# Backup fstab
cp /etc/fstab /etc/fstab.bak

# Install utils if missing
if ! rpm -q amazon-efs-utils; then
    dnf install -y amazon-efs-utils
fi

# Add to fstab
if ! grep -q "${efs_id}" /etc/fstab; then
  echo "${efs_id}:/ /var/www/html efs _netdev,tls,iam 0 0" >> /etc/fstab
fi

# Attempt Mount
mount_custom() {
    for i in {1..5}; do
        mount -a -t efs defaults && return 0
        echo "Mount failed, retrying in 5s..."
        sleep 5
    done
    return 1
}

mount_custom || echo "CRITICAL: EFS Mount Failed. Proceeding with local storage."

# 5. Smart Installation Logic
CONFIG_FILE="/var/www/html/wp-config.php"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "FRESH INSTALL: wp-config.php not found on EFS."
    
    # Clone Repo to /tmp to avoid EFS write issues during clone
    echo "Cloning Repository to /tmp..."
    cd /tmp
    rm -rf MercadoLocal-MX-Site
    git clone https://github.com/CarlosSuarezCWH/MercadoLocal-MX-Site.git
    
    if [ -d "MercadoLocal-MX-Site" ]; then
        echo "Cloning successful. Moving files..."
        
        # Move files to EFS
        cp -r MercadoLocal-MX-Site/* /var/www/html/
        # Also copy hidden files like .htaccess if they exist, but ignore .git
        # (cp with globbing can be tricky, using rsync would be better but simple cp -r * covers visible)
        # cp -r MercadoLocal-MX-Site/.[!.]* /var/www/html/ 2>/dev/null 
        
        cd /var/www/html
        
        # Inject Database Credentials
        # Assumes the repo has a wp-config.php. If not, this might fail, but user said their repo "add db" 
        # usually implies full site backup or starter.
        # User repo listing showed wp-config.php.
        
        if [ -f "wp-config.php" ]; then
            echo "Configuring wp-config.php..."
            # We need to make sure we don't double replace if we run this multiple times (though check above prevents it)
            # The user's wp-config.php probably has hardcoded values or placeholders. 
            # We will try to replace common placeholders or just append/define if not present?
            # Safer to assume standard constants are there OR we just rewrite them.
            # Given we can't see the file content, the safest is to do what we did before but targeting the existing file.
            
            # NOTE: If the user's wp-config.php has hardcoded credentials, we should probably REPLACE them.
            # But we don't know the exact string to replace (e.g. 'localhost').
            # So standard practice: simple sed replacement of common defines if possible, 
            # Or better yet, append them if we want to override (but PHP constants can't be redefined).
            
            # Strategy: Simple search and replace for standard define patterns.
            
            sed -i "s/define( *'DB_NAME', *'.*' *);/define( 'DB_NAME', '${db_name}' );/" wp-config.php
            sed -i "s/define( *'DB_USER', *'.*' *);/define( 'DB_USER', '${db_username}' );/" wp-config.php
            sed -i "s/define( *'DB_PASSWORD', *'.*' *);/define( 'DB_PASSWORD', '${db_password}' );/" wp-config.php
            sed -i "s/define( *'DB_HOST', *'.*' *);/define( 'DB_HOST', '${db_host}' );/" wp-config.php

            # Generate Random AUTH KEYS if requested or just append if missing?
            # Existing site implies existing keys in wp-config.php. We probably shouldn't rotate them 
            # unless we know they are dummy values. For now, let's LEAVE KEYS ALONE from the repo 
            # to match the DB setup (especially for logged in users cookie validity).
            
        else
            echo "WARNING: wp-config.php not found in repo. Creating from sample..."
            if [ -f "wp-config-sample.php" ]; then
                cp wp-config-sample.php wp-config.php
                sed -i "s/database_name_here/${db_name}/" wp-config.php
                sed -i "s/username_here/${db_username}/" wp-config.php
                sed -i "s/password_here/${db_password}/" wp-config.php
                sed -i "s/localhost/${db_host}/" wp-config.php
                curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php
            fi
        fi

        # Permissions
        chown -R apache:apache /var/www/html
        chmod -R 755 /var/www/html
        
        echo "Code successfully deployed."

        # Database Import
        DB_DUMP="db/shop_carlosmancera_com.sql"
        if [ -f "$DB_DUMP" ]; then
            echo "Database dump found at $DB_DUMP. Importing..."
            # Check if DB is empty to avoid overwriting production data on a re-mount (though this is FRESH INSTALL block)
            # Wait for valid connection
            echo "Waiting for DB connection..."
            until mysql -h "${db_host}" -u "${db_username}" -p"${db_password}" -e "SELECT 1"; do
                echo "Waiting for DB..."
                sleep 5
            done
            
            mysql -h "${db_host}" -u "${db_username}" -p"${db_password}" "${db_name}" < "$DB_DUMP"
            
            if [ $? -eq 0 ]; then
                echo "Database import successful."
            else
                echo "ERROR: Database import failed."
            fi
        else
            echo "No database dump found at $DB_DUMP."
        fi

    else
        echo "ERROR: Failed to clone repository."
    fi
else
    echo "EXISTING INSTALL: wp-config.php found on EFS. Skipping install."
    if id "apache" &>/dev/null; then
        chown -R apache:apache /var/www/html
    fi
fi

# 7. ALWAYS ensure SSL/HTTPS Fix matches Load Balancer (Patching)
# This block runs on every boot to fix any missing configuration
if [ -f "$CONFIG_FILE" ]; then
    if ! grep -q "HTTP_X_FORWARDED_PROTO" "$CONFIG_FILE"; then
        echo "Patching wp-config.php for SSL..."
        cat <<EOF >> "$CONFIG_FILE"

/** Fix for AWS ALB HTTPS */
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    \$_SERVER['HTTPS'] = 'on';
}
if (!defined('WP_HOME')) {
    define('WP_HOME', 'https://shop.carlosmancera.com');
}
if (!defined('WP_SITEURL')) {
    define('WP_SITEURL', 'https://shop.carlosmancera.com');
}
if (!defined('WP_CACHE')) {
    define('WP_CACHE', true);
}
if (!defined('WP_REDIS_HOST')) {
    define('WP_REDIS_HOST', '${redis_host}');
}
if (!defined('WP_REDIS_PORT')) {
    define('WP_REDIS_PORT', ${redis_port});
}
EOF
    fi
fi

# 6. Restart Apache
systemctl restart httpd
