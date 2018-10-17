#!/bin/bash

echo
echo " #################################"
echo " ### Welcome! Multi-Kubernetes Cluster Install with DCOS Edge-LB###"
echo " #################################"
echo

echo "Checking to see if DC/OS CLI is Installed and Configured to DC/OS Cluster"
# Make sure the DC/OS CLI is available
result=$(which dcos 2>&1)
if [[ "$result" == *"no dcos in"* ]]
then
        echo
        echo " ERROR: The DC/OS CLI program is not installed. Please install it."
        echo " Follow the instructions found here: https://docs.mesosphere.com/1.10/cli/install/"
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

read -p "DCOS must be configured to access cluster over HTTPS before proceeding. Continue? (y/n) " -n1 -s c
if [ "$c" = "y" ]; then

dcos config set core.ssl_verify false

echo "DCOS Cluster has been set to ssl_verify = False"
echo

fi
#Configure Kubernetes CLI

read -p "Install Kubernetes Cluster for Dev, ? (y/n) " -n1 -s c
if [ "$c" = "y" ]; then

dcos package install kubernetes --options=dev-options.json

fi

read -p "Install Kubernetes Cluster for Prod, ? (y/n) " -n1 -s c
if [ "$c" = "y" ]; then

dcos package install kubernetes --options=prod-options.json

fi

read -p "Install Edge-LB for Exposing API-Backend and K8s UI, ? (y/n) " -n1 -s c
if [ "$c" = "y" ]; then

echo "Installing Edgelb v1.2.0 repos and running package installation..."

dcos package repo add --index=0 edgelb-aws https://downloads.mesosphere.com/edgelb/v1.2.0/assets/stub-universe-edgelb.json
echo
dcos package repo add --index=0 edgelb-pool-aws https://downloads.mesosphere.com/edgelb-pool/v1.2.0/assets/stub-universe-edgelb-pool.json
echo
dcos package install edgelb

echo "Waiting for edge-lb to come up. Ignore errors while it waits for Pool to start..."
	until dcos edgelb ping; do sleep 1; done

echo "Installing the EdgeLB CLI"

  dcos package install edgelb --cli
  echo
  sleep 3

echo "Creating Pool Configuration for Prod and Dev API Server Frontends through Kubectl Proxy"

	dcos edgelb create DCOS-multik8.json

fi

echo "Please wait while Kubernetes finishes installing in Dev and Prod..
in another terminal you can run the commands

     'dcos kubernetes --name=dev/kubernetes plan show deploy'
     'dcos kubernetes --name=prod/kubernetes plan show deploy'

When all tasks show as COMPLETED then proceed to the next steps"

read -p "Please wait until both Kubernetes Installs are completed!...
and then click y to proceed to configuration of kubeconfig, ? (y/n) " -n1 -s c
if [ "$c" = "y" ]; then

  echo "Please Enter the Public Node that 'multik8s-kubectl-proxy' is running on: "

            read -p 'Enter Public IP manually here once you identify it: ' PUBLICNODEIP
            PUBLICNODEIP=$PUBLICNODEIP

            dcos kubernetes --name="kubernetes.dev" kubeconfig --apiserver-url=https://$PUBLICNODEIP:7000 --insecure-skip-tls-verify
            dcos kubernetes --name="kubernetes.prod" kubeconfig --apiserver-url=https://$PUBLICNODEIP:7001 --insecure-skip-tls-verify

fi

echo "Congratulations! You have successfully installed multiple kubernetes clusters over Edge-LB!"
echo
echo "Opening Kubernetes Dashboard for Prod over Local Host using Kubectl Proxy. To load the other dashboard,
switch your context to the Dev cluster and re-run kubectl proxy"

kubectl proxy
