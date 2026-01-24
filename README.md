# 🛒 MercadoLocal-MX: Cloud E-commerce Platform

## 📑 Propuesta Técnica de Infraestructura AWS
Esta solución responde al RFP de MercadoLocal MX, implementando un CMS (WordPress) altamente disponible, escalable y seguro.

### 🏗️ Arquitectura de Red y Cómputo
- **Topología Multi-AZ:** Despliegue en 2 Zonas de Disponibilidad para garantizar disponibilidad del 99.9%.
- **Segmentación de Red:** - Subnets Públicas para el Application Load Balancer (ALB).
  - Subnets Privadas para la capa de Aplicación (EC2) y Datos (RDS).
- **Escalamiento:** Auto Scaling Group (ASG) con políticas de capacidad mínima y máxima (1-3 instancias).

### 🔒 Seguridad y Control
- **RDS No Público:** La base de datos reside en la capa privada, aislada de internet.
- **Acceso Administrativo:** Gestión mediante AWS Systems Manager (SSM) Session Manager, eliminando la necesidad de SSH (Puerto 22) abierto.
- **Principio de Privilegio Mínimo:** Uso de IAM Instance Profiles para acceso a S3 sin llaves estáticas.

### ⚙️ Desacoplamiento (Funcionalidad Lambda)
Se implementó un microservicio asíncrono mediante **AWS Lambda**. Cuando se carga una imagen de producto al Bucket S3, la Lambda se dispara automáticamente para procesamiento y optimización de medios, cumpliendo con el requisito de backend desacoplado.

### 🚀 Despliegue Automatizado
Infraestructura desplegada mediante un pipeline de CI/CD en GitHub Actions.