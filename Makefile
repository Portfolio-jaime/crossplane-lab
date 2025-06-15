# Variables
CLUSTER_NAME=crossplane-lab
NAMESPACE=crossplane-system
AWS_SECRET_NAME=aws-secret
AWS_REGION=us-east-1
ENV_FILE=.env

# Cargar variables desde el archivo .env
include $(ENV_FILE)
export $(shell sed 's/=.*//' $(ENV_FILE))

# Objetivos
.PHONY: all clean cluster install-crossplane setup-aws apply-resources open-docs create-keypair apply-ec2

all: cluster install-crossplane setup-aws apply-resources create-keypair apply-ec2

clean:
    @echo "Eliminando el clúster..."
    kind delete cluster --name $(CLUSTER_NAME)

cluster:
    @echo "Creando el clúster de Kubernetes..."
    kind create cluster --name $(CLUSTER_NAME)

install-crossplane:
    @echo "Instalando Crossplane..."
    helm repo add crossplane-stable https://charts.crossplane.io/stable
    helm repo update
    helm install crossplane --namespace $(NAMESPACE) --create-namespace crossplane-stable/crossplane
    @echo "Esperando a que los pods de Crossplane estén listos..."
    kubectl wait --for=condition=ready pod -n $(NAMESPACE) --all --timeout=300s

setup-aws:
    @echo "Creando el secreto de AWS..."
    kubectl create secret generic $(AWS_SECRET_NAME) -n $(NAMESPACE) \
        --from-literal=aws_access_key_id=$(AWS_ACCESS_KEY_ID) \
        --from-literal=aws_secret_access_key=$(AWS_SECRET_ACCESS_KEY)
    @echo "Aplicando configuraciones de proveedores..."
    kubectl apply -f crossplane/Config-crossplane/provider-aws.yaml

apply-resources:
    @echo "Aplicando configuraciones de recursos..."
    kubectl apply -f crossplane/AWS-resources/ec2-instance.yaml

open-docs:
    @echo "Abriendo documentación en el navegador..."
    "$BROWSER" https://crossplane.io/docs/

create-keypair:
    @echo "Creando el par de claves en AWS..."
    aws ec2 create-key-pair --key-name crossplane-lab-keypair --query 'KeyMaterial' --output text > crossplane-lab-keypair.pem
    @chmod 600 crossplane-lab-keypair.pem
    @kubectl create secret generic ec2-keypair-secret -n crossplane-system --from-file=keypair.pem=crossplane-lab-keypair.pem

apply-ec2:
    @echo "Aplicando el recurso EC2..."
    @kubectl apply -f crossplane/AWS-resources/ec2-instance.yaml
