# Script to automate custom cluster creation using Rancher API for API call demonstration
This is an effort to create a script to create custom cluster using Rancher API from CLI.

# Pre-Requisite:
A new node spinned up by any hypervisor, its IP and credentials.
The node node should be reachable with the privided ip address and the username and password should be mentioned in respective files correctly
The IP is to be mentioned in ipaddress file.

# Steps
This logic behind this script is:

1. There is a *ipaddress.txt* file in the root location.

2. When a node spins up in any hypervisor like vmware vsphere we get the ipadress of it, that ip needs to be added in here.
   Multiple IPs can be added for multinode cluster

3. The monitor.sh will monitor the ipadress file and as soon as it finds that it has been modified it will execute the cluster creation script.

4. You will have to modify the cluster creation script to add:
   
   *1. RANCHER_UR*
   
   *2. RANCHER_ACCESS_KEY*
   
   *3. RANCHER_SECRET_KEY*
   
   *4. SSH_USERNAME*
   
   *5. RANCHER_USERNAME --> *ONLY USED FOR EMPTY CLUSTER DELETION -- "Passwordless Authentication is required"**
   
   *6. RANCHER_FQDN  --> ONLY USED FOR EMPTY CLUSTER DELETION*

6. You will have to add the the node password in the password file in plain text present in the root location (Risky but thats how it is as of now).
   If you have passwordless authentication set then you can comment this step and modify the ssh command at the bottom of the script

7. When the script is run it will first check for the max supported kubernetes version from RANCHER server or in the SUSE Support matrix if that code snippet is enabled
   *--> You can comment this and hardcode the value of you want*

8. The script will first validate is the mentioned ip is accessible or not and only continue if it is.

9. With the base version received it will then search the RKE2 github release page to check and find the latest RKE2 stable version of the supported base version found

8. With all the details it will connect to Rancher and spin up a cluster with a random name starting with cluster-5 digit random number

9. Once the cluster is spin up it will fetch the cluster id, cluster registration url and set ip as a variable.

10. If it doesnt finds a cluster id it will fail if it finds it will continue

11. It will check connectivity to the IP mentioned in the IP file and ssh into those nodes and execute the registration command.

12. If the connectivity is affected or broken then it will fail and delete the Empty cluster from Rancher Server if it is reachable it will continue.

13. If Multiple IP is there it will ssh into each one and execute the registration command

14. Finally it will clear the ip file for use again and to avoid duplication.

Please note: This is for testing and not intended to use for production. If you want to use it please use it at your own risk.!!!!
