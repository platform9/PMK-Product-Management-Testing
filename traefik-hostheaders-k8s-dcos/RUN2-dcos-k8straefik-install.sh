#!/bin/bash


echo
echo " #########################################################################"
echo " ### Traefik Ingress Controller Configuration and Install on DCOS-K8s  ###"
echo " #########################################################################"
echo

echo "######PLESSE CHECK THE FOLLOWING PRE-REQUISITES BEFORE INSTALL! ########"
echo
echo "1. You have installed kubernetes with exactly 1 Public Node in RUN1 options.json"
sleep 2

echo "2. You have found the public kubelet's node IP by running
'kubectl describe node kube-node-public-0-kubelet.kubernetes.mesos'"
sleep 2

echo "3. You have edited your local machines '/etc/hosts' file with
'<public-kubernetes-node-IP'> www.k8sdcos-cheddar.com"
sleep 2

echo "Once you have finished the pre-requisites, please continue with the rest of the installation...."
sleep 2

read -p "Are you ready to install Traefik now, ? (y/n) " -n1 -s c
if [ "$c" = "y" ]; then

echo "Creating RBAC Cluster Role and Service Account for Traefik Controller"

  kubectl create -f traefik-rbac.yaml

echo

sleep 3

echo "Deploying Main Traefik Ingrees Controller on Public Node"

  kubectl create -f traefikcontroller-k8s.yaml

sleep 3

echo "Deploying Dameonset for Traefik on all Nodes"

  kubectl apply -f traefik-ds.yaml

sleep 3

echo "Configuring Tiller and Installing Helm for Traefik Web UI (optional)"
#Deploy traefik UI

  kubectl apply -f traefik-ui.yaml

#Deploy Tiller on your K8s Cluster

  kubectl -n kube-system create serviceaccount tiller
  kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
  helm init --service-account tiller
  echo "Waiting for Tiller to be Running"
  sleep 15

#Deploy Helm Chart for traefik Dashboard and Frontend Access to Services

echo "Installing Traefik Helm Chart - Latest v1.7.2"

  helm install stable/traefik --name my-release --namespace kube-system

  echo
  echo
  sleep 5

echo "Installing Example Web-Services Configuration with Named-Based Routing to Traefik Ingress Controller.

NOTE: This will install all pods, services, and ingress rules needed, but will expose ONLY the cheddar web service running NGINX
The other 2 web services will not be resolvable on your network unless you expose the service over a designated portDefinitions
and configure a working hostname inside your /etc/hosts file

This is not needed 'for' this demo, but you can accomplish this by:

1. Simply configuring the 'hostname' field within the cheese-ingress.yaml file
2. Adding the hostnames to your /etc/hosts file of your 'local' machine like we have configured 'for' cheddar
3. Exposing the service using the commands:

      kubectl expose service stinton --port=443 --target-port=8444 --name=stinton-http
      kubectl expose service cheddar --port=443 --target-port=8445 --name=wensleydale-http"

read -p "Do you want to continue, ? (y/n) " -n1 -s c
if [ "$c" = "y" ]; then

  echo "Deploying Application PODS with apps Cheddar, Stilton, and Wesleydale..."
      kubectl create -f cheese-pods.yaml

      sleep 3
  echo

  echo "Configuring 3 kubernetes services configurations on PODs"
      kubectl create -f cheese-webservices.yaml

      sleep 3
  echo

  echo "Deploying Ingress Configuration with Hostname Headers designated inside cheese-ingress.yaml file"
      kubectl create -f cheese-ingress.yaml

      sleep 3
  echo

echo "Exposing the cheddar hostname for ingress over the public kubelet using configured header 'www.k8sdcos-cheddar.com'"

kubectl expose service cheddar --port=443 --target-port=8443 --name=cheddar-http

echo "Finished!

You can now verify the installation directly with the hostname of the cheddar service...

Note: This can also be located via the Træfik dashboard where you should see a frontend for each host"
sleep 3

echo "Opening broswer now with hostname header for cheddar web service (NGINX Homepage) in a moment"
sleep 7
open http://k8sdcos-cheddar.com

fi

else

echo no
fi
