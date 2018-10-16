#!/bin/bash


echo
echo  "PRE-REQUISITES

In order to test hostname headers in Traefik, please...

1. Install kubernetes with exactly 1 Public Node inside the DC/OS GUI (HA is optional)
2. Find the public kubelet's node IP by running 'run 'kubectl describe node 'kube-node-public-0-kubelet.kubernetes.mesos'
3. Edit your local machine's ''/etc/hosts' file with the '<public-kubernetes-node-IP'> www.k8sdcos-cheddar.com'

Note: In this example we are using only 1 out of the 3 cheese services to illustrate hostname headers
and the ability to link these back to backend pods and loadbalancers via a single Traefik controller

Once you have finished the pre-requisites, please continue.."

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

NOTE: This will install all pods, services, and ingress rules to expose ONLY the cheddar web service running NGINX
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

  echo "Deploying Application POD called Cheese"
      kubectl create -f cheese-pods.yaml

      sleep 3
  echo

  echo "Configuring 3 Example Web Services on PODs"
      kubectl create -f cheese-webservices.yaml

      sleep 3
  echo

  echo "Deploying Ingress Configuration for Hostname Headers using Kubernetes node names and Mesos DNS"
      kubectl create -f cheese-ingress.yaml

      sleep 3
  echo

else

echo no
exit

echo "Exposing the cheddar hostname over the public kubelet using configured header www.k8sdcos-cheddar.com"

kubectl expose service cheddar --port=443 --target-port=8443 --name=cheddar-http
echo

echo "Finished!

You can now verify the installation directly with the hostname of the cheddar service"

echo "Opening the configured hostname to show nginx running on the cheddar web service"
open http://k8sdcos-cheddar.com

echo "This can be located via the Træfik dashboard where you should see a frontend for each host"

fi
