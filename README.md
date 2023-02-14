# Cours Kubernetes

## Mardi
### Créer un déploiement à partir d'un manifest
- Créer à partir de la CLI :
```bash
kubectl create deployment nginx --image=nginx
```
Regarder le résultat :
```bash
kubectl get deployments
kubectl get pods
kubectl describe pods
kubectl describe deployments nginx
```
- Créer à partir d'un manifest :
Il faut d'abord [écrire un manifest](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#writing-a-deployment-spec) (= fichier yaml décrivant la structure souhaitée du déploiement), puis l'appliquer :
```bash
kubectl apply -f nginx-deployment.yaml
```

Regarder le résultat :
```bash
kubectl get deployments
kubectl get pods
kubectl describe pods
kubectl describe deployments nginx
```

On peut exécuter un shell dans un des pods pour voir ce qu'il se passe dedans :
```bash
kubectl exec -it <nom_du_pod> -- sh
```
