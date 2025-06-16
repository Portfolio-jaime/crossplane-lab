# Crossplane Lab con Dev Containers

Este laboratorio demuestra cómo administrar infraestructura de AWS (instancia EC2, bucket S3, VPC y Subnet) usando **Crossplane** a través de manifiestos de Kubernetes. El entorno de _Dev Container_ provee un espacio aislado y reproducible, utilizando Docker y Kubernetes dentro del contenedor.

---

## Objetivo Principal

Proveer, gestionar y eliminar servicios de AWS (EC2, S3, VPC, Subnet) utilizando manifiestos de Kubernetes.

---

## Diagrama de Arquitectura

```mermaid
flowchart TD
    A[VS Code]:::vscode --> B{Dev Container}:::devcontainer
    A -. Lee/Monta .aws/credentials .-> D1[~/.aws/credentials]:::cred
    D1 -.-> B
    B --> C[Terminal de VS Code]:::terminal
    B --> D[Docker CLI]:::docker
    C --> E[kubectl]:::cli
    C --> F[Helm]:::cli
    C --> G[Kind]:::cli
    D --> H[Docker Daemon]:::docker
    G -- Crea --> I[Kubernetes Cluster]:::k8s
    I --> J[Crossplane]:::crossplane
    J --> K[Provider AWS]:::aws
    K -- Provee/Gestiona --> L[VPC]:::awsres
    L -- Contiene --> M[Subnet]:::awsres
    M -- Es usada por --> N[Instancia EC2]:::awsres
    K -- Provee/Gestiona --> O[S3 Bucket]:::awsres

    style A fill:#007acc,stroke:#333,stroke-width:1px,color:#fff
    style B fill:#229977,stroke:#333,stroke-width:1px,color:#fff
    style C fill:#727272,stroke:#333,stroke-width:1px,color:#fff
    style D fill:#2496ed,stroke:#333,stroke-width:1px,color:#fff
    style D1 fill:#f7e018,stroke:#333,stroke-width:1px,color:#000
    style E fill:#154360,stroke:#333,stroke-width:1px,color:#fff
    style F fill:#154360,stroke:#333,stroke-width:1px,color:#fff
    style G fill:#154360,stroke:#333,stroke-width:1px,color:#fff
    style H fill:#384d54,stroke:#333,stroke-width:1px,color:#fff
    style I fill:#326ce5,stroke:#333,stroke-width:1px,color:#fff
    style J fill:#1694f5,stroke:#333,stroke-width:1px,color:#fff
    style K fill:#ee6b2f,stroke:#333,stroke-width:1px,color:#fff
    style L fill:#ffc107,stroke:#333,stroke-width:1px,color:#000
    style M fill:#ffe082,stroke:#333,stroke-width:1px,color:#000
    style N fill:#ffb300,stroke:#333,stroke-width:1px,color:#000
    style O fill:#ffc107,stroke:#333,stroke-width:1px,color:#000
    classDef cred fill:#f7e018,stroke:#333,stroke-width:1px,color:#000
    classDef docker fill:#384d54,stroke:#333,stroke-width:1px,color:#fff
```

En este diagrama se observa cómo VS Code (a través de un Dev Container) interactúa con herramientas como `kubectl`, `Helm` y `Kind` para crear un clúster de Kubernetes en el cual se instala Crossplane con el proveedor de AWS. Dicho proveedor maneja la creación de recursos como instancia EC2, bucket S3, VPC y Subnet directamente en AWS.

---

## Estructura del Proyecto

```
crossplane-lab/
├── .devcontainer/
│   ├── crossplane-lab.code-workspace
│   ├── devcontainer.json
│   ├── docker-compose.yml
│   └── Dockerfile
├── crossplane/
│   ├── AWS-resources/
│   │   ├── ec2-instance.yaml
│   │   ├── s3-bucket.yaml
│   │   ├── subnet.yaml
│   │   └── vpc.yaml
│   ├── Config-crossplane/
│   │   ├── provider-aws.yaml
│   │   └── provider-config-aws.yaml
├── README.md
├── .gitignore
├── .env
├── create-key-par.sh
└── Makefile
```

---

## Guía Paso a Paso

### 1. Prerrequisitos en tu Máquina (Host)
1. **Docker Desktop** en ejecución.  
2. **Visual Studio Code** con la extensión *Remote - Containers*.  
3. **Credenciales de AWS** configuradas localmente con:
   ```bash
   aws configure
   ```
   Asegúrate de que tu archivo `~/.aws/credentials` esté correcto.

### 2. Iniciar el Entorno y Configurar Credenciales
1. Abre esta carpeta (`crossplane-lab`) en VS Code.  
2. Elige **"Reopen in Container"** para iniciar el Dev Container que ya trae Docker, Kubernetes CLI, Helm y otras herramientas.  
3. Dentro del contenedor, configura AWS si lo deseas:
   ```bash
   aws configure
   ```

### 3. Preparar el Clúster de Kubernetes
1. Crea el clúster con Kind:
   ```bash
   make cluster
   ```
2. Verifica los nodos:
   ```bash
   kubectl get nodes
   ```
   Deberás ver un nodo en estado `Ready`.

### 4. Instalar Crossplane y Configurar AWS
1. Instala **Crossplane**:
   ```bash
   make install-crossplane
   ```
2. Crea el secreto de AWS para las credenciales:
   ```bash
   make setup-aws
   ```
3. Aplica la configuración de proveedores:
   ```bash
   make apply-resources
   ```

### 5. Crear el Par de Claves y Aplicar el Recurso EC2
1. Genera el par de claves en AWS:
   ```bash
   make create-keypair
   ```
2. Aplica el manifiesto de EC2:
   ```bash
   make apply-ec2
   ```
3. Verifica el estado del recurso:
   ```bash
   kubectl get instances.ec2.aws.upbound.io -o wide
   ```

### 6. (Opcional) Provisionar Otros Recursos
1. **Bucket S3**:
   ```bash
   kubectl apply -f crossplane/AWS-resources/s3-bucket.yaml
   ```
2. **VPC**:
   ```bash
   kubectl apply -f crossplane/AWS-resources/vpc.yaml
   ```
3. **Subnet**:
   ```bash
   kubectl apply -f crossplane/AWS-resources/subnet.yaml
   ```

### 7. Limpieza
1. Eliminar recursos individualmente:
   ```bash
   kubectl delete -f crossplane/AWS-resources/<resource-file>.yaml
   ```
2. Eliminar el clúster:
   ```bash
   make clean
   ```

---

## Notas Finales
Este laboratorio está diseñado para ser completamente reproducible y aislado, para que puedas explorar Crossplane sin afectar tu configuración local. Si surge algún problema, verifica los registros de los pods de Crossplane:

```bash
kubectl logs -n crossplane-system <pod-name>
```

¡Disfruta aprendiendo sobre la gestión de infraestructura con Kubernetes y Crossplane!
