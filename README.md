Instructions for Setting up Multiple Kubernetes on DC/OS using Prod and Dev Clusters 

**** Pre-requisites - 2 Kubernetes clusters ****
-/prod/kubernetes running with HA enabled
-/dev/kubernetes running with HA enabled
****

Setup EdgeLB and configure the pool

1. Install Edge-LB
2. Install CLI for Edge-LB
3. dcos marathon app add kube-proxy-prod.json
4. dcos marathon app add kube-proxy-dev.json
5. dcos edgelb create multi-k8s-edgepool.json

Setup API Servers for prod and dev in kubeconfig

PROD
---Set the service name for prodkubernetes---

  dcos config set kubernetes.service_name /prod/kubernetes

----Configure for kubeconfig----

    dcos kubernetes kubeconfig --apiserver-url=http://PUBLICNODEIP \
    --insecure-skip-tls-verify

----IMPORTANT - unset user and delete context then set a cluster name----
for dev in order to clear the local kubeconfig on your local machine

    kubectl config get-contexts
    kubectl config unset users.ID#OFCONTEXT
    kubectl config delete-context 52133484
    kubectl config set-cluster ID#OFCONTEXT

DEV
----Set the service name for devkubernetes----

  dcos config set kubernetes.service_name /dev/kubernetes
  dcos kubernetes kubeconfig --apiserver-url=http://52.13.34.84 \
    --insecure-skip-tls-verify

NOTE: If you get any errors it is most likely from stale contexts
clusters, or set users still in the Kubeconfig

Do a

kubectl config get-contexts
kubectl config unset users.ID#OFCONTEXT
kubectl config delete-context ID#OFCONTEXT
kubectl config delete-cluster ID#OFCONTEXT

And then re-riun the dcos kubernetes kubeconfig command again
