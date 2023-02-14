#! /bin/bash

echo "Deploying Redis leader & followers..."
kubectl apply -f ../redis/redis-leader-service.yaml
kubectl apply -f ../redis/redis-follower-service.yaml
kubectl apply -f ../redis/redis-leader-deployment.yaml
kubectl apply -f ../redis/redis-follower-deployment.yaml

echo "Deploying Frontend..."
kubectl apply -f ../front/front-service.yaml
kubectl apply -f ../front/front-deployment.yaml

echo "Frontend is available at http://localhost:8080"
kubectl port-forward svc/frontend 8080:80 -n front
