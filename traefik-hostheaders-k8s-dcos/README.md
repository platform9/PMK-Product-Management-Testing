README------------------

Consolidated Instructions for Deploying and Testing Traefik in K8s on DC/OS 
Leverages several up to date Traefik items https://github.com/containous/traefik/blob/master/docs/user-guide/

To Install the DEMO:

Ensure you have atleast 2 Public Nodes and 8 Private Nodes in DC/OS EE

THen....

I. Run the RUN1 dcos-k8s-install.sh script to configure K8s with options file for 1 public node 

-------------Steps Executed by Script(s) Below ---------------------
      
      *** Installs Kubernetes with 1 Public Node
      *** Installs Marathon-LB 
      *** Deploys maraton app for kubectl proxy to server UI over localhost:8001
      *** Configures api-server in kubeconfig to set api-server url backend for MLB
   
   BEFORE GOING ON TO STEP 2:
   
   - Identify which public node the public-kubelet sits on (Execute findpublicips.sh script and use 
     the one which is not for marathonlb)
     
   - Edit your local /etc/hosts file with '<public-IP-kubelet> www.cheese-cheddar.com www.cheese-wesleydale.com www.cheese-stinton.com'
   
   - Edit your local /etc/hosts file with '<YOUR-KUBE_PUBLIC_IP> kube-node-0-kubelet.kubernetes.mesos' 
   *** This will allow you to access the traefik UI over http://kube-node-0-kubelet.kubernetes.mesos ***

II. Run the RUN2 dcos.k8s.traefik-install.sh script to deploy ingress, pods, ds, brace, tiller, and 
   web services    
   
-------------Steps Executed by Script(s) Below ---------------------

1. Deploys Ingress Controller nad Traefik UI

    *** Deploys Traefik with Cluster Role Binding and rbac
    *** Deploys Traefik Controller Configuration
    *** Confirms Deployment
    *** Deploys traefik UI Helm Chart
          - Deploys Tiller on your K8s Cluster
          - Creates service account for Tiller
          - Assigns cluster role for cluster-admin to SA
          - Installs Helm Chart for Traefik UI 1.7.2 

2. Configures Test Example for Named-Based Routing Using NGINX-based 'Cheese Web Services'

   *** Creates PODs for Cheese App (Cheddar, Stilton and Wesleydale)
   *** Deploys Services on PODs
   *** Deploys Ingress for cheese
   *** Exposes the cheddar service for NGINX over port 8443 on the public kubelet 
          - Leverages the hostname header from the ingress rules in cheese-ingress.yaml

When you visit the Træfik dashboard, you should see a frontend for each hostname
along with a backend listing for each service with a server set up for each pod. 

If you have configured the hostname header in your /etc/hosts file correctly, you can go directly to the hostname
in your browser of choice

Open the hostname www.cheese-cheddar.com to view the 'cheddar' welcome page
Open the hostname with www.cheese-wesleydale.com to view the 'wesleydale' welcome page
Open the hostname with www.cheese-wesleydale.com to view the 'wesleydale' welcome page

Note: If you are using this in production, then this would be done using your own chosen domains and DNS server
