#!/bin/bash

# Crear el par de claves en AWS
aws ec2 create-key-pair --key-name crossplane-lab-keypair --query 'KeyMaterial' --output text > crossplane-lab-keypair.pem

# Proteger el archivo de clave privada
chmod 600 crossplane-lab-keypair.pem

# Crear el secreto en Kubernetes
kubectl create secret generic ec2-keypair-secret -n crossplane-system --from-file=keypair.pem=crossplane-lab-keypair.pem

# Aplicar el recurso EC2
kubectl apply -f crossplane/AWS-resources/ec2-instance.yaml

echo "Par de claves creado y recurso EC2 aplicado."