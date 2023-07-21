#!/bin/bash
###Set the authentication#####
RANCHER_URL="https://rancher.domain.com" ##--->MODIFY 
CATTLE_ACCESS_KEY="" ##--->MODIFY 
CATTLE_SECRET_KEY=""  ##--->MODIFY
APITOKEN="$CATTLE_ACCESS_KEY:$CATTLE_SECRET_KEY"
##Generating Random Cluster name####
CLUSTER_NAME="cluster-$((RANDOM % 90000 + 10000))"
##Checking max supported k8s version for rke2 downstream####
echo "Checking max supported k8s version for rke2 downstream cluster"
SUPPORTED_MAX_BASE_VERSION=$(curl -s https://www.suse.com/suse-rancher/support-matrix/all-supported-versions/rancher-v2-7-5/ | grep -i -A10 "Downstream Cluster Support" | grep "1.2*" | grep -v -i heading | awk {'print $1'} | head -n 1 | grep -oP '(?<=<td>).*?(?=</td>)')
RKE2_K8S_VERSION=$(curl -s https://api.github.com/repos/rancher/rke2/releases | jq -r '.[].tag_name' | grep -E '^v'$SUPPORTED_MAX_BASE_VERSION'' | grep -v -E 'rc|alpha|beta' | sort -V | tail -n 1)
echo "RKE2 version to be used is $RKE2_K8S_VERSION"
####Setting Node Credetials####
SSH_USERNAME="root" ##--->MODIFY
read -r SSH_PASSWORD < ./password.txt ##--->MODIFY in password file not here
###
echo "Creating CLuster with given details"
CREATE_CLUSTER_RESPONSE=$(curl -k -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" -s  $RANCHER_URL/v1/provisioning.cattle.io.clusters -H 'content-type: application/json' --data-raw '{"type":"provisioning.cattle.io.cluster","metadata":{"namespace":"fleet-default","name":"'$CLUSTER_NAME'"},"spec":{"rkeConfig":{"chartValues":{"rke2-calico":{}},"upgradeStrategy":{"controlPlaneConcurrency":"1","controlPlaneDrainOptions":{"deleteEmptyDirData":true,"disableEviction":false,"enabled":false,"force":false,"gracePeriod":-1,"ignoreDaemonSets":true,"skipWaitForDeleteTimeoutSeconds":0,"timeout":120},"workerConcurrency":"1","workerDrainOptions":{"deleteEmptyDirData":true,"disableEviction":false,"enabled":false,"force":false,"gracePeriod":-1,"ignoreDaemonSets":true,"skipWaitForDeleteTimeoutSeconds":0,"timeout":120}},"machineGlobalConfig":{"cni":"calico","disable-kube-proxy":false,"etcd-expose-metrics":false},"machineSelectorConfig":[{"config":{"protect-kernel-defaults":false}}],"etcd":{"disableSnapshots":false,"s3":null,"snapshotRetention":5,"snapshotScheduleCron":"0 */5 * * *"},"registries":{"configs":{},"mirrors":{}},"machinePools":[]},"machineSelectorConfig":[{"config":{}}],"kubernetesVersion":"'$RKE2_K8S_VERSION'","defaultPodSecurityAdmissionConfigurationTemplateName":"","localClusterAuthEndpoint":{"enabled":false,"caCerts":"","fqdn":""}}}')
##
sleep 10
echo "Fetching CLuster Id"
CLUSTERID=$(curl -s ${RANCHER_URL}/v3/clusters?name=${CLUSTER_NAME} -H 'content-type: application/json' -H "Authorization: Bearer $APITOKEN" --insecure | jq -r .data[].id)
if [ -n "$CLUSTERID" ]; then
	echo "Cluster ID fetched - Cluster ID is $CLUSTERID - Continuing further to fetch registration url"
	sleep 10
	echo "Fetching Registration URL"
	REGISTRATION_RESPONSE=$(curl -k -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" --request GET $RANCHER_URL/v3/clusters/$CLUSTERID/clusterregistrationtokens --header 'Content-Type: application/json')
	sleep 10
	REGISTRATION_LINK=$(echo "${REGISTRATION_RESPONSE}" | jq -r '.data[0].insecureNodeCommand')
	REGISTRATION_URL=""$REGISTRATION_LINK" --worker --controlplane --etcd"
	echo "Registration URL is "$REGISTRATION_URL""
	echo "Executing Registration URL in Node"
#####
	input_file="./ipaddress.txt"
	remote_file=/etc/rancher/rke2/rke2.yaml
	mkdir ./$CLUSTER_NAME
	localpath=./$CLUSTER_NAME/
	mapfile -t ip_addresses < ./ipaddress.txt
	for ip_address in "${ip_addresses[@]}"; do
		 echo "Found IP Address/es $ip_address"
		echo "Checking if ssh can be done"
		sshpass -p "$SSH_PASSWORD" ssh -q -o StrictHostKeyChecking=no "$SSH_USERNAME"@"$ip_address" exit
		if [ $? -eq 0 ]; then
			echo "SSH Connection is successful..Continuing with Registering to cluster"
			echo "Running remote SSH command on $ip_address"
			sshpass -p "$SSH_PASSWORD" ssh -v -o StrictHostKeyChecking=no "$SSH_USERNAME"@"$ip_address" "$REGISTRATION_URL"
			sleep 30
			sshpass -p "$SSH_PASSWORD" scp "$SSH_USERNAME"@"$ip_address":"$remote_file" "$localpath"
			echo "Cluster created cleaning up IP file"
			echo > $input_file
			echo "RKE2 Cluster with name $CLUSTER_NAME created successfully on node $ip_address and the kube config file has been saved as /root/$CLUSTER_NAME/config.yaml"
		else
			echo "SSH connection failed. Terminating...Please check connectivity and retry"
			exit 1
		fi
		done
else
	echo "Couldnt Fetch Cluster ID - Seems Like there is a problem - Terminating the script - Please rectify and rerun"
	exit 1
fi
