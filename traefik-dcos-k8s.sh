#!/bin/bash

read -p "Are you ready to install Traefik, ? (y/n) " -n1 -s c
if [ "$c" = "y" ]; then

  kubectl create -f traefik-rbac.yaml
  kubectl create -f traefik-k8s.yaml
  kubectl apply -f traefik-ds.yaml

echo
echo
echo "Deploying Traefik Configuration with RBAC, DaemonSet, and Hostname Header Best Practices"

echo "Configuring Tiller"
#Deploy traefik UI

  kubectl apply -f traefik-ui.yaml

#Deploy Tiller on your K8s Cluster

  kubectl -n kube-system create serviceaccount tiller
  kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
  helm init --service-account tiller
  sleep 20
  echo "Waiting for Tiller to be Running"

#Deploy Helm Chart for traefik Dashboard and Frontend Access to Services

echo "Installing Traefik Helm Chart - Latest v1.7.2"

  helm install stable/traefik --name my-release --namespace kube-system

#create sample application and services for ingress

echo "Deploying Test Example with Named-Based Routing for Traefik Ingress to Backends"

echo "Deploying Application POD called Cheese"
    kubectl create -f cheese-pod.yaml
echo

echo "Configuring 3 Services on PODs"
    kubectl create -f cheese-webservices.yaml
echo

echo "Deploying Ingress Configuration using Mesos DNS"
    kubectl create -f cheese-ingress
echo

echo "Finished! You can now verify the installation directly with the hostname of each service. These can be located via the Træfik dashboard where you should see a frontend for each host along with a backend listing for each service with a server set up for each pod"
fi

else
        echo no
fi
