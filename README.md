# Déployer Kubernetes sur Google Cloud (Compute Engine)

Ce projet s'appuie sur les outils d'automatisation (terraform, ansible, docker, etc.) pour automatiser le déploiement de 4 vms (2 masters, 2 workers ️) 
kubernetes sur GCE.

## Comment ça marche ? 
- Mettez votre fichier d'authentification `cred.json` (récupéré depuis votre compte GCloud) dans le répertoire `deploy`.
- Si besoin choisissez la région et la zone où vous voulez deployer votre infra.
- Executez `./install.sh`, il va construire une image de docker (basé sur le `Dockerfile`) et lancer un conteneur avec tous les outils nécessaires
dans le conteneur.
 ### vous serez automatiquement connecté au conteneur !!!
- Executez `./create.sh` 
il va créer toutes les ressources gce et les configurer.
  ### Attention !!!  Durée +/- 10mins 

## Nettoyage
- Lorsque vous avez terminé, executez `./cleanup.sh` pour supprimer toutes les ressources gce.



## Crédits 👍
Ce travail est basé sur :
 ### [k8s-on-gce](https://github.com/Zenika/k8s-on-gce) 
 ### [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
