#!/bin/bash

# 1. Install Dependencies for Amazon Linux 2023
dnf update -y
dnf install -y httpd php php-mysqlnd php-gd php-xml php-mbstring php-opcache php-pecl-redis amazon-efs-utils git

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
    
    # Download to /tmp to avoid EFS write issues during download
    echo "Downloading WordPress to /tmp..."
    cd /tmp
    rm -f latest.tar.gz
    curl -O https://wordpress.org/latest.tar.gz
    
    if [ -f latest.tar.gz ]; then
        echo "Extracting WordPress..."
        tar -xzf latest.tar.gz
        
        echo "Moving files to EFS..."
        cp -r wordpress/* /var/www/html/
        
        cd /var/www/html
        cp wp-config-sample.php wp-config.php
        
        # Inject Database Credentials
        sed -i "s/database_name_here/${db_name}/" wp-config.php
        sed -i "s/username_here/${db_username}/" wp-config.php
        sed -i "s/password_here/${db_password}/" wp-config.php
        sed -i "s/localhost/${db_host}/" wp-config.php

        # Generate Random AUTH KEYS
        curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php
        
        # Permissions
        chown -R apache:apache /var/www/html
        chmod -R 755 /var/www/html
        
        echo "WordPress successfully installed."
    else
        echo "ERROR: Failed to download WordPress archive."
    fi
else
    echo "EXISTING INSTALL: wp-config.php found."
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
define('WP_HOME', 'https://shop.carlosmancera.com');
define('WP_SITEURL', 'https://shop.carlosmancera.com');
define('WP_CACHE', true);
define('WP_REDIS_HOST', '${redis_host}');
define('WP_REDIS_PORT', ${redis_port});
EOF
    fi
fi

# 6. Restart Apache
systemctl restart httpd
