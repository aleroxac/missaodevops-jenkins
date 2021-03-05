#!/usr/bin/env bash

# ---------- VARIABLES ----------
dockerhub_user=aleroxac
jenkins_port=8080
image_name=missaodevops-jenkins
image_version=3.0.0
container_name=jenkins
KUBERNETES_SERVER_URL="$(kubectl config view -o json | jq -r '.clusters[-1]["cluster"]["server"]')"
# JENKINS_SERVER_URL="$(docker inspect jenkins -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}'):8080" 
JENKINS_SERVER_URL="http://172.17.0.3:8080"


# ---------- SETTING BUILD WORKSPACE ----------
if [ ! -d downloads ]; then
    mkdir downloads
    curl -o downloads/jdk-8u144-linux-x64.tar.gz http://ftp.osuosl.org/pub/funtoo/distfiles/oracle-java/jdk-8u144-linux-x64.tar.gz
    curl -o downloads/jdk-7u80-linux-x64.tar.gz http://ftp.osuosl.org/pub/funtoo/distfiles/oracle-java/jdk-7u80-linux-x64.tar.gz
    curl -o downloads/apache-maven-3.5.2-bin.tar.gz http://mirror.vorboss.net/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz
fi

# ---------- REMOVING OLD JENKINS CONTAINER ----------
docker rm -f ${container_name}


# ---------- SETTING K8S ----------
minikube node list | grep "172" > /dev/null || minikube start
kubectx minikube
kubectl create namespace jenkins
kubectl create sa jenkins -n jenkins
kubectl create rolebinding jenkins-admin-binding --clusterrole=admin --serviceaccount=jenkins:jenkins -n jenkins
K8S_KEY=$(kubectl get secret $(kubectl describe sa jenkins -n jenkins | grep Token | awk '{print $2}') -o jsonpath='{.data.token}' -n jenkins)

# ---------- BUILDING THE CONTAINER IMAGE ----------
[ ! -d m2deps ] && mkdir m2deps
[ -d jobs ] && rm -rf jobs || mkdir jobs

docker build \
    -t "${dockerhub_user}/${image_name}:${image_version}" \
    --build-arg KUBERNETES_SERVER_URL="${KUBERNETES_SERVER_URL}" \
    --build-arg JENKINS_SERVER_URL="${JENKINS_SERVER_URL}" \
    --build-arg K8S_KEY="${K8S_KEY}" \
    --build-arg MASTER_IMAGE_VERSION="${image_version}" \
    --no-cache "${PWD}"


# ---------- RUNNING THE CONTAINER ----------
docker run -p ${jenkins_port}:8080 \
    -e KUBERNETES_SERVER_URL="$(kubectl config view -o json | jq -r '.clusters[-1]["cluster"]["server"]')" \
    -e JENKINS_SERVER_URL="localhost:8080" \
    -v "${PWD}/jobs:/var/jenkins_home/jobs/" \
    -v "${PWD}/m2deps:/var/jenkins_home/.m2/repository/" \
    -v "${HOME}/.ssh:/var/jenkins_home/.ssh/" \
    --rm -d --name ${container_name} \
    ${dockerhub_user}/${image_name}:${image_version}
