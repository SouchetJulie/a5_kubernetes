# Cours Kubernetes

## Lundi
**Kubernetes** = orchestrateur de conteneurs

Architecture :

- _Nœud_ = machine physique ou virtuelle
- _Cluster_ = ensemble de machines (nœuds) qui exécutent des conteneurs
- _Pod_ = ensemble de conteneurs qui partagent un réseau et un espace de stockage, gérés par le control plane
- _Conteneur_ = processus isolé qui exécute une application (par ex. Docker)
- _Control plane_ = ensemble de processus qui gère le cluster (maître)
- _Déploiement_ = ensemble de pods gérés ensemble
- _ReplicaSet_ = permet de dupliquer des pods (scalabilité)

Outils :

- Minikube = outil pour lancer facilement un cluster Kubernetes local ([installation](https://minikube.sigs.k8s.io/docs/start/))
- Kubectl = CLI pour interagir avec un cluster Kubernetes ([installation](https://kubernetes.io/docs/tasks/tools/))

Cf. [tuto](https://kubernetes.io/docs/tutorials/hello-minikube/)

N.B. : On peut utiliser des raccourcis pour les commandes kubectl : `po` pour `pods`, `rs` pour `replicaset`, `deploy` pour `deployment`, etc.


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
kubectl apply -f practice-1/nginx-deployment.yaml
```

N.B. : On peut créer le manifest depuis le CLI, sans créer le déploiement, avec : (merci @YannyOuzid)
```bash
kubectl create deployment nginx --image=nginx:latest --dry-run=client -o yaml > nginx-deployment.yaml
```

Regarder le résultat :
```bash
kubectl get deploy
kubectl get po
kubectl describe po
kubectl describe deploy nginx
```

On peut exécuter un shell dans un des pods pour voir ce qu'il se passe dedans (on récupère le nom depuis `get`) :
```bash
kubectl exec -it <nom_du_pod> -- sh
```

### Services
Expose une application à l'extérieur du cluster, a son propre IP ([docs](https://kubernetes.io/docs/concepts/services-networking/service/))

Depuis la CLI :
```bash
kubectl expose deployment nginx-deployment --port=80 --type=NodePort
```
Le type détermine comment le service est exposé :
- ClusterIP : accessible uniquement depuis l'intérieur du cluster
- NodePort : accessible depuis l'extérieur du cluster, via un port sur chaque nœud
- LoadBalancer : accessible depuis l'extérieur du cluster, via un load balancer externe
- ExternalName : redirige vers un nom DNS externe
- etc.

Avec minikube, ouvre dans le navigateur par défaut l'URL du service :
```bash
minikube service nginx
```

Depuis un manifest : (docs)
```bash
kubectl apply -f practice-1/nginx-service.yaml
```

Puis on forward le port du service vers la machine locale :
```bash
kubectl port-forward service/nginx-service 8080:80
```

On peut maintenant y accéder depuis `localhost:8080` tant que le port-forwarding est actif :)

N.B. : Pour le sens inverse (accéder à des services externes depuis l'intérieur du cluster), on peut utiliser un [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/).


### EndpointSlices
Permet de suivre les endpoints réseaux ([docs](https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/))
