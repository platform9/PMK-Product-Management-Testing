# tomcat-demo
Example of Tomcat sample.war running inside docker in DCOS and exposing outside cluster
--------------------------------
What is needed:
-----------------------------------
1. DCOS Cluster setup and configured CLI
2. marathon config for tomcat json
3. edgelb package installed
4. edgelb --cli package installed
5. edgelb pool config json
6. a sample .war file for use in URI fetching with step #2

Demo Instructions:

1. Install EdgeLb Repos and EdgeLB Package

    dcos package repo add --index=0 edgelb-aws \
      https://downloads.mesosphere.com/edgelb/v1.0.2/assets/stub-universe-edgelb.json
    dcos package repo add --index=0 edgelb-pool-aws \
      https://downloads.mesosphere.com/edgelb-pool/v1.0.2/assets/stub-universe-edgelb-pool.json
  
    dcos package install edgelb
    dcos package install edgelb --cli

2. Create EdgeLb Pool and Deploy Tomcat 
    
    edgelb create tomcatpoollb.json
    dcos marathon app add tomcat.json

3. Tomcat will be exposed over port 8080

    Find your public ip
    Once deployed, the app will be exposed on https://<your-public-ip>:8080/<nameofwar> (in this case '8080/sample')

Note the 'cmd' field in the json config 

mv /mnt/mesos/sandbox/sample.war /usr/local/tomcat/webapps/sample.war 
&& /usr/local/tomcat/bin/catalina.sh run”. 

After deploying it will fetch the URI and then run the catalina.sh startup to start the tomcat app in the foreground

Note: do not use the /startup.sh as this wont persist and will loop a finished container endlessly

---------------------


