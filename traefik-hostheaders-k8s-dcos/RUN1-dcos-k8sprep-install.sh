#!/bin/bash

# Get DC/OS Master Node URL

echo
echo " #########################################################"
echo " ### DCOS-Kubernetes API-Server Configuration Install  ###"
echo " #########################################################"
echo

# Make sure the DC/OS CLI is available
result=$(which dcos 2>&1)
if [[ "$result" == *"no dcos in"* ]]
then
        echo
        echo " ERROR: The DC/OS CLI program is not installed. Please install it."
        echo " Follow the instructions found here: https://docs.mesosphere.com/1.11/cli/install/"
        echo " Exiting."
        echo
        exit 1
fi

# Get DC/OS Master Node URL
MASTER_URL=$(dcos config show core.dcos_url 2>&1)
if [[ $MASTER_URL != *"http"* ]]
then
        echo
        echo " ERROR: The DC/OS Master Node URL is not set."
        echo " Please set it using the 'dcos cluster setup' command."
        echo " Exiting."
        echo
        exit 1
fi

# Check if the CLI is logged in
result=$(dcos node 2>&1)
if [[ "$result" == *"No cluster is attached"* ]]
then
    echo
    echo " ERROR: No cluster is attached. Please use the 'dcos cluster attach' command "
    echo " or use the 'dcos cluster setup' command."
    echo " Exiting."
    echo
    exit 1
fi
if [[ "$result" == *"Authentication failed"* ]]
then
    echo
    echo " ERROR: Not logged in. Please log into the DC/OS cluster with the "
    echo " command 'dcos auth login'"
    echo " Exiting."
    echo
    exit 1
fi
if [[ "$result" == *"is unreachable"* ]]
then
    echo
    echo " ERROR: The DC/OS master node is not reachable. Is core.dcos_url set correctly?"
    echo " Please set it using the 'dcos cluster setup' command."
    echo " Exiting."
    echo
    exit 1

fi

echo
echo "DC/OS CLI Setup Correctly"
echo

#Configure Kubernetes CLI
read -p "Install DCOS Kubernetes and CLI, ? (y/n) " -n1 -s c
if [ "$c" = "y" ]; then

dcos package install kubernetes --options=options.json
dcos package install kubernetes --cli

fi
# Install marathon-lb for IaaS level ingest to K8s Framework
echo "Deploying Marathon-LB..."

dcos package install marathon-lb
sleep 25

# Configure api server and deploy Kubernetes Dashboard over Local Host using Kube proxy

echo "Adding Kube-Proxy to DC/OS Cluster..."
dcos marathon app add kubectl-proxy.json
echo
echo
echo
echo
echo "Waiting for Kubernetes to come up...this usually take about 120 seconds..."
dcos kubernetes plan show deploy
sleep 20
echo "Waiting for Kubernetes to come up...20 seconds"
dcos kubernetes plan show deploy
sleep 20
echo "Waiting for Kubernetes to come up...40 seconds"
dcos kubernetes plan show deploy
sleep 20
echo "Waiting for Kubernetes to come up...60 seconds"
dcos kubernetes plan show deploy
sleep 20
echo "Waiting for Kubernetes to come up...80 seconds"
dcos kubernetes plan show deploy
sleep 20
echo "Waiting for Kubernetes to come up...100 seconds"
dcos kubernetes plan show deploy
sleep 20
echo "Waiting for Kubernetes to come up...120 seconds"
dcos kubernetes plan show deploy
sleep 20

        read -p 'Enter Public IP manually when Kubernetes is finished installing (COMPLETED): ' PUBLICNODEIP
        PUBLICNODEIP=$PUBLICNODEIP

echo "Configuring Kubeconfig to use the DCOS-Kubernetes API Server URL for Frontend Traffic and Kubernetes Dashboard"
sleep 10
echo

dcos kubernetes kubeconfig --context-name=k8sdcos --apiserver-url https://$PUBLICNODEIP:6443 --insecure-skip-tls-verify --name="kubernetes"

echo
echo
echo
echo .

echo "Finished! You can now execute the traefik.sh script to deploy the example web app with ingress and hostname headers"
echo
echo .

echo "Starting Kubctl Dashboard over localhost at http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/http:kubernetes-dashboard:/proxy/

NOTE: Please open a new terminal to keep kubectl proxy running on your local host!
You can now proceed to RUN2 in order to install the Traefik Controller and example web services for ingress"

kubectl proxy
