#!/bin/bash

if ! [ -x "$(command -v kubectl)" ]; then
  echo 'First kubectl on your path... bye :)'
  exit 1
fi

echo
echo " #########################################################"
echo " ### Kubernetes API-Server Configuration Install  ###"
echo " #########################################################"
echo

# Configure api server and deploy Kubernetes Dashboard over Local Host using Kube proxy

        read -p 'Enter Public IP of the Kubelet manually: ' PUBLICNODEIP
        PUBLICNODEIP=$PUBLICNODEIP

echo "Configuring Kubeconfig to use the DCOS-Kubernetes API Server URL for Frontend Traffic and Kubernetes Dashboard"
sleep 10
echo

kubectl config set --context-name=default --apiserver-url https://$PUBLICNODEIP:6443 --insecure-skip-tls-verify --name="kubernetes"

echo
echo
echo
echo .

echo "Finished! You can now execute the traefik.sh script to deploy the example web app with ingress and hostname headers"
echo
echo .

echo "Starting kubectl Dashboard over localhost at http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/
NOTE: Please open a new terminal to keep kubectl proxy running on your local host!
You can now proceed to RUN2 in order to install the Traefik Controller and example web services for ingress"

kubectl proxy
