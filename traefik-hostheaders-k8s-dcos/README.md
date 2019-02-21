Consolidated Instructions for Deploying and Testing Traefik in K8s on DC/OS 
Leverages several up to date Traefik items https://github.com/containous/traefik/blob/master/docs/user-guide/

To Install the DEMO:

Ensure you have atleast 3 workers, and atleast 1 public kubelet 

I. Run the RUN1 dcos-k8s-install.sh script to configure K8s with options file for 1 public node 

-------------Steps Executed by Script(s) Below ---------------------
      
      *** Configures api-server in kubeconfig to set api-server url
      *** Deploys kubectl proxy to serve UI over localhost:8001
   
   BEFORE GOING ON TO STEP 2:
   
   - Identify the public IP of the node for the public-kubelet
     
   - Edit your local /etc/hosts file with 
   "public-IP-kubelet" www.cheese-cheddar.com www.cheese-wesleydale.com www.cheese-stinton.com'
   
   - Edit your local /etc/hosts file with 
   "public-IP-kubelet" <DNS Name for Kubelet Node>
   *** This will allow you to access the traefik UI over public nodes DNS name ***

II. Run the RUN2 dcos.k8s.traefik-install.sh script to deploy ingress, pods, ds, tiller, and web services    
   
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
   
   *** Exposes the cheese service over port 8443 on the public kubelet 
   
          - Leverages the hostname header from the ingress rules in cheese-ingress.yaml

When you visit the Træfik dashboard, you should see a frontend for each hostname
along with a backend listing for each service with a server set up for each pod. 

If you have configured the hostname header in your /etc/hosts file correctly, you can go directly to the hostnames
in your browser of choice

Open the hostname www.cheese-cheddar.com to view the 'cheddar' welcome page

Open the hostname with www.cheese-stinton.com to view the 'stinton' welcome page

Open the hostname with www.cheese-wesleydale.com to view the 'wesleydale' welcome page

Note: If you are using this in production, then this would be done using your own chosen domains and DNS server
