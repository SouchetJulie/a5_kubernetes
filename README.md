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

On peut aussi ajouter un alias bash tel que `alias k=kubectl` pour simplifier encore plus.


## Mardi matin

### Créer un déploiement à partir d'un manifest
- Créer à partir de la CLI :
```bash
kubectl create deploy nginx --image=nginx
```
Regarder le résultat :
```bash
kubectl get deploy
kubectl get po
kubectl describe po
kubectl describe deploy nginx
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
kubectl expose deploy nginx-deployment --port=80 --type=NodePort
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

⚠️ Ne pas oublier d'activer le port forwarding vers la machine locale (sinon le service ne reste accessible que depuis le cluster avec type=ClusterIP) :
```bash
kubectl port-forward service/nginx-service 8080:80
```

On peut maintenant y accéder depuis `localhost:8080` tant que le port-forwarding est actif :)

N.B. : Pour le sens inverse (accéder à des services externes depuis l'intérieur du cluster), on peut utiliser un [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/).



## Mardi après-midi

Construction d'un cluster multi-tier (front + back) avec Kubernetes.

Cf. [tuto](https://kubernetes.io/docs/tutorials/stateless-application/guestbook/)

Pour créer les namespaces :
```bash
./practice-2/bin/create_guestbook_ns.sh
```

Pour déployer les différentes pods :
```bash
./practice-2/bin/deploy_guestbook.sh
```

Une fois fini, on peut nettoyer avec :
```bash
./practice-2/bin/clean_guestbook.sh
```

## Mercredi matin

### Volumes
Permettent de stocker des données persistantes, en dehors des pods.

Le storageClassName permet de déterminer de quel type de volume il s'agit (local, dans le cloud, etc.).
On peut configurer les droits d'accès, la taille, etc.

Créer deux volumes de 1Gi et 1Mi respectivement :
```bash
kubectl apply -f practice-3/tuto-pv/pv.yaml
```
Regarder le résultat :
```bash
kubectl get pv
```
Créer un volume claim de 500Mi :
```bash
kubectl apply -f practice-3/tuto-pv/pvc.yaml
```
Regarder le résultat :
```bash
kubectl get pv
kubectl get pvc
```
On voit que c'est le volume de 1Gi qui a été utilisé, car c'est le seul qui est suffisamment grand.

On peut ensuite l'utiliser dans le pod qu'on veut.
Par exemple, on peut créer un pod qui utilise ce volume :
```bash
kubectl apply -f practice-3/tuto-pv/pod.yaml
```

Puis, on vérifie que le volume est bien monté dans le pod :
```bash
kubectl exec -it pod-practice-pv -- sh
```
Dans le shell :
```bash
apt update
apt install curl
curl http://localhost/
```
On voit que le contenu du volume est bien affiché.

Nettoyage : (L'ordre est important ! Si on essaie de supprimer un volume qui est encore utilisé, il restera en "terminating" indéfiniment.) 
```bash
kubectl delete pod -l td=pv
kubectl delete pvc -l td=pv
kubectl delete pv -l td=pv
```
Dans le shell de minikube (`minikube ssh`) :
```bash
sudo rm -rf /mnt/data
```

### Une application avec MySQL
On définit un secret pour le mot de passe de l'utilisateur root :
```bash
kubectl create secret generic mysql-pass --from-literal=password=secret
```

Déployer les pv, pvc et le déploiement de MySQL :
```bash
kubectl apply -f practice-3/stateful/mysql-pv.yaml -f practice-3/stateful/mysql-deploy.yaml
```
Une fois que le déploiement est prêt (vérifier avec `kubectl get po`), on crée un déploiement avec un client MySQL :
```bash
kubectl apply -f practice-3/stateful/mysql-client-deploy.yaml
```
On peut ensuite se connecter au client :
```bash
kubectl exec -it <nom_du_pod> -- sh
```

Nettoyage :
```bash
kubectl delete deploy,svc,pvc,pv -l app=mysql
minikube ssh
sudo rm -rf /mnt/data
```
