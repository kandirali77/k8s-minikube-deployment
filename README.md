# k8s-minikube-deployment
This repo will have files to build and deploy a simple ruby webserver on minikube
My test environment is MacbookAir running MacOS Big Sur 11.6 with 8Gb memory on Intel architecture

The simple webserver will be taken from https://github.com/sawasy/http_server

## Installation of kubernetes
We need to install kubernetes for deploying and running the dockerized images. You may follow the instructions here:
https://kubernetes.io/docs/tasks/tools/ depending on your operating system.  
On Mac I have installed kubectl with homebrew: https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#install-with-homebrew-on-macos  
```bash
$ brew install kubectl
```

## Installation of minikube
When you install minikube on your local machine you may follow this instructions: https://minikube.sigs.k8s.io/docs/start/
```bash
$ brew install minikube
```

If you already have a local installation and the start up has problems do the following:  
***ref***: https://github.com/kubernetes/minikube/issues/8770 and https://github.com/kubernetes/minikube/issues/11417
```bash
$ minikube delete --all --purge
$ minikube start
```
*ps.* make sure that you don't have any previous setup on your minikube. You will loose them with the above commands.

### Enable docker-env feature to use minikube as build environment
Minikube can be used as a docker environment to be able to build our docker images. Please run the command to enable this feature.
```bash
$ eval $(minikube -p minikube docker-env)
```
*ps.* if you have more than one minikube profile, name the appropriate one after "-p" option  

This way we can use **docker** command to build images in the same environment where we are going to deploy them.

### Enabling ingress dns for web access to minikube from local laptop
Minikube has the ability to respond DNS queries for local deployments. We can enable this feature with this command:
```bash
$ minikube addons enable ingress-dns
```

After that, we can follow the instructions to use test domain within our local environment.  
***ref***: https://minikube.sigs.k8s.io/docs/handbook/addons/ingress-dns/#add-the-minikube-ip-as-a-dns-server

For Mac, you may follow these steps. Other environments are explained above reference.

```bash
# Find minikube IP address
$ minikube ip
192.168.99.106
#
# Populate the /etc/resolver/minikube-minikube-test file with the required information. Change the minikube IP to your deployment.
$ sudo bash -c 'cat << EOF > /etc/resolver/minikube-minikube-test
domain test
nameserver 192.168.99.106
search_order 1
timeout 5
EOF'
#
# Test the minikube ingress dns addon
$ nslookup http-server.test $(minikube ip)
Server:		192.168.99.106
Address:	192.168.99.106#53

Non-authoritative answer:
Name:	http-server.test
Address: 192.168.99.106
#
# Test the local laptop resolution
$ ping http-server.test
PING http-server.test (192.168.99.106): 56 data bytes
64 bytes from 192.168.99.106: icmp_seq=0 ttl=64 time=0.397 ms
64 bytes from 192.168.99.106: icmp_seq=1 ttl=64 time=2.706 ms
64 bytes from 192.168.99.106: icmp_seq=2 ttl=64 time=0.419 ms
#
# Local dns resolution for domain "test" is done
```

## Getting the source code of the webserver into our project
We will use submodule tool of the git software.  
***ref***: https://git-scm.com/book/en/v2/Git-Tools-Submodules  
Submodules are a reference to a separate repository and do not keep code in our own repository. Instead just a commit
reference is enough.

When cloning this repository
1. You may opt to clone with the submodule
```bash
$ git clone --recurse-submodules https://github.com/kandirali77/k8s-minikube-deployment.git
```
2. or you may choose for later download of the code in submodule
```bash
$ git submodule update --init
```

## Creating the docker images

We will use the Docker file under the root folder of our project to create the docker images locally.
We have chosen to use **ruby:3.0-alpine3.12** image to run they ruby source code. The latest version of
alpine linux is 3.14 available from ruby docker hub but to download additional code into the docker image
we have to use 3.12 version of alpine. The issue was reported here: https://githubmemory.com/repo/alpinelinux/docker-alpine/issues/185

To create you docker images on local minikube instance:
```bash
$ docker build -t local/http_server:0.0.1 .
```
The above command will build the docker image and keep it in local images of minikube. We will use this image on kubernetes deploys.

## Deploying http_server with kubernetes
I have prepared kubernetes files under "k8s" folder. These files will deploy the http_server with two replicas and a service. The ingress will ensure the dns resolution of "http-server.test" will reply in a load balanced manner with readiness and liveness probes.   
Readiness probe on deployment will not forward traffic to the pods until it is ready and liveness probe will make sure that pods keep running.

To deploy the application run the following command from the root directory of this project:

```bash
$ kubectl create -f k8s
deployment.apps/http-server-deployment created
ingress.networking.k8s.io/http-server-ingress created
service/http-server created
service/http-server created
```

# Strategy/Architecture of the http_server application deployment
The strategy behind this setup is to deploy a simple ruby application with readiness and liveness probes. The application has an endpoint for health checks on "/healthcheck" but it does not return any HTTP header code. Besides the application returns text with HTTP0.9 and kubernetes health checks require HTTP1.1 to function properly.  
I have overcome this problem with "exec" probe. I curled ***http://localhost/healthcheck*** and compared returned text with "OK" returning "0" when the text is correct. This way, we are sure that the container is running and operating normally. The readiness probe will forward traffic once the container is up and running and liveness probe will restart the container when the returned value from probe is non-zero.
```bash
livenessProbe:
  exec:
    command:
    - /bin/sh
    - -c
    - '[[ $(/usr/bin/curl --http0.9 -s http://localhost/healthcheck) == "OK" ]]'
  initialDelaySeconds: 15
  periodSeconds: 5
readinessProbe:
  exec:
    command:
    - /bin/sh
    - -c
    - '[[ $(/usr/bin/curl --http0.9 -s http://localhost/healthcheck) == "OK" ]]'
```

The planned architecture for the http_server deployment is here:  
![The architecture diagram of minikube deployment!](/k8s-minikube-http_server.png "Architecture diagram of minikube deployment")

# Step-by-step installation instructions
Please follow [INSTALL.md](INSTALL.md) file for the instructions. 

# How to connect to the running application
Once all steps are followed from this readme file, you can open your favourite browser and type "http://http-server.test"  
You will see a similar result as below:  

![Web browser request and result](/firefox-web-response.png "Web browser request and result")
