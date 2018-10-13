#!/bin/bash

read -p "Are you ready to install Traefik, ? (y/n) " -n1 -s c
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

read -p "Installing Example Web-Services Configuration with Named-Based Routing to Traefik Ingress Controller.

NOTE: This will install all pods, services, and ingress rules but will use default hostnames that are not resolvable on
your network should you haven not already followed the pre-requisites...

In order to show working frontends in your browser, please edit the cheese-ingress.yaml with your own provide domain and
configure the hostname IPs in your /etc/hosts file of your local machine.

Do you want to continue, ? (y/n) " -n1 -s c
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

fi

echo "Finished!

You can now verify the installation directly with the hostname of each service.

These can be located via the Træfik dashboard where you should see a frontend for each host

You can also view them directly in your browser using the hostname headers and domain in your cheese-ingress.yaml"

fi
