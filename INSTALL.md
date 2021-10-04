These instructions are for MacOS deployment of the application
1. Install kubectl
```bash
$ brew install kubectl
```

2. Install Minikube
```bash
$ brew install minikube
```

3. Enable docker-env feature
```bash
$ eval $(minikube -p minikube docker-env)
```

4. Enable "ingress dns" addon
```bash
$ minikube addons enable ingress-dns
```

5. Create DNS resolution within Macbook
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
```
6. Test your DNS setup
```bash
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
```

7. Clone this repo
```bash
$ git clone --recurse-submodules https://github.com/kandirali77/k8s-minikube-deployment.git
$ cd k8s-minikube-deployment
```

8. Create docker image inside Minikube
```bash
$ docker build -t local/http_server:0.0.1 .
```

9. Deploy kubernetes application
```bash
$ kubectl create -f k8s
deployment.apps/http-server-deployment created
ingress.networking.k8s.io/http-server-ingress created
service/http-server created
service/http-server created
```

10. Run on the web browser
Open your browser of choice and go to address "http://http-server.test"

You will see the result as below:  
![Web browser request and result](/firefox-web-response.png "Web browser request and result")
