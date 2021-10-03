# k8s-minikube-deployment
This repo will have files to build and deploy a simple ruby webserver on minikube
Our test environment is MacbookAir running MacOS Big Sur 11.6 with 8Gb memory on Intel architecture

The simple webserver will be taken from https://github.com/sawasy/http_server

## Installation of minikube
When you install minikube on your local machine you may follow this instructions: https://minikube.sigs.k8s.io/docs/start/

If you already have a local installation and the start up has problems do the following:  
***ref***: https://github.com/kubernetes/minikube/issues/8770 and https://github.com/kubernetes/minikube/issues/11417
```bash
minikube delete --all --purge
minikube start
```
*ps.* make sure that you don't have any previous setup on your minikube. You will loose them with the above commands.

### Enable docker-env feature to use minikube as build environment
Minikube can be used as a docker environment to be able to build our docker images. Please run the command to enable this feature.
```bash
eval $(minikube -p minikube docker-env)
```
*ps.* if you have more than one minikube profile, name the appropriate one after "-p" option  

This way we can use **docker** command to build images in the same environment where we are going to deploy them.

## Getting the source code of the webserver into our project
We will use submodule tool of the git software.  
***ref***: https://git-scm.com/book/en/v2/Git-Tools-Submodules  
Submodules are a reference to a separate repository and do not keep code in our own repository. Instead just a commit
reference is enough.

When cloning this repository
1. You may opt to clone with the submodule
```bash
git clone --recurse-submodules https://github.com/kandirali77/k8s-minikube-deployment.git
```
2. or you may choose for later download of the code in submodule
```bash
git submodule update --init
```
