#!/bin/bash

# Set variables
REGION="us-east-2"
CLUSTER_NAME="my-cluster"
DEPLOYMENT_NAME="nginx"
SERVICE_NAME="nginx"

# Update kubeconfig to use the EKS cluster
echo "Updating kubeconfig for cluster $CLUSTER_NAME..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Check nodes to verify connection
echo "Getting nodes..."
kubectl get nodes
kubectl get nodes --output=wide

# Create an NGINX deployment
echo "Creating deployment $DEPLOYMENT_NAME..."
kubectl create deployment $DEPLOYMENT_NAME --image=nginx

# Expose the deployment as a NodePort service
echo "Exposing deployment $DEPLOYMENT_NAME as service $SERVICE_NAME..."
kubectl expose deployment $DEPLOYMENT_NAME --port=80 --type=NodePort

# Wait for service to be created
sleep 10

# Get details of the service to find the NodePort
echo "Getting service details..."
kubectl get svc $SERVICE_NAME

# Optionally, edit the service to view or update configuration
# Uncomment the following line if you need to manually edit the service
# kubectl edit svc $SERVICE_NAME

# Get nodes again to verify connectivity
echo "Getting nodes again..."
kubectl get nodes -o wide

echo "Setup complete."

