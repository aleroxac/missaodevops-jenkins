#!/usr/bin/env bash


# ---------- VARIABLES ----------
dockerhub_user=aleroxac
jenkins_port=8080
image_name=missaodevops-jenkins
image_version=3.0.0
container_name=jenkins
folders=( jobs m2deps .ssh )
jenkins_password="jenkins"


# ---------- CHANGING WORKING DIRECTORY ----------
cd "resources/v.${image_version}" || return


# ---------- SETTING BUILD WORKSPACE ----------
function cleanBuildWorkspace() {
    for folder in "${folders[@]}"; do
        if [ -d "${folder}" ]; then
            sudo rm -rf "${folder}"
        fi

        mkdir -pv "${folder}"
        if [ "${folder}" == ".ssh" ]; then
            echo ${jenkins_password} > "${folder}"/.password
            cp ~/.ssh/id_rsa* .ssh
        fi
    done
}
function getTools() {
    if ! ls -l downloads/*.gz 2> /dev/null > /dev/null; then
        xdg-open "https://drive.google.com/u/0/uc?id=1oFuhDkStvfqpYiZZm6C2s99TWsr8QgTk&export=download"

        while true; do
            read -rp "Confirma que o download foi completado? (S/n): " finish
            case $finish in 's') break ;; esac
        done

        mkdir -p downloads
        unzip -d downloads ~/Downloads/tools.zip
    fi
}


# ---------- SETTING K8S ----------
function createCluster() {
    minikube ip > /dev/null || minikube start
    kubectl get ns | grep -q jenkins  || kubectl create namespace jenkins

    if kubectl config current-context | grep -q minikube; then
        kubectl config set-context minikube --namespace jenkins
    fi
}
function creteServiceAccount() {
    if ! kubectl get sa | grep -q jenkins; then
        kubectl create serviceaccount jenkins --namespace jenkins
    fi
}
function creteRoleBinding() {
    if ! kubectl get rolebindings | grep -q jenkins; then
        kubectl create rolebinding jenkins-admin-binding \
            --clusterrole admin \
            --serviceaccount jenkins:jenkins \
            --namespace jenkins
    fi
}
function getServiceAccountToken() {
    K8S_SA_TOKEN=$(kubectl describe sa jenkins -n jenkins | grep Token | awk '{print $2}')
    K8S_SA_TOKEN_SECRET=$(kubectl get secret "${K8S_SA_TOKEN}" -o jsonpath='{.data.token}' -n jenkins)

    K8S_KEY=$(echo "${K8S_SA_TOKEN_SECRET}" | base64 --decode -)
    KUBERNETES_SERVER_URL="$(kubectl config view -o json | jq -r '.clusters[-1]["cluster"]["server"]')"

    export K8S_KEY
    export KUBERNETES_SERVER_URL
}


# ---------- BUILDING THE CONTAINER IMAGE ----------
function buildJenkinsContainerImage() {
    echo "${KUBERNETES_SERVER_URL}"
    docker build \
        -t "${dockerhub_user}/${image_name}:${image_version}" \
        --build-arg KUBERNETES_SERVER_URL="${KUBERNETES_SERVER_URL}" \
        --build-arg K8S_KEY="${K8S_KEY}" \
        --build-arg MASTER_IMAGE_VERSION="${image_version}" \
        --no-cache "${PWD}"
}
# ---------- REMOVING THE CONTAINER ----------
function deleteJenkinsContainer() {
    docker ps | grep -q ${container_name} && docker rm -f ${container_name}
}
# ---------- RUNNING THE CONTAINER ----------
function runJenkinsContainer() {
    deleteJenkinsContainer
    getServiceAccountToken
    docker run -p ${jenkins_port}:${jenkins_port} \
        -e KUBERNETES_SERVER_URL="${KUBERNETES_SERVER_URL}" \
        -v "${PWD}/jobs:/var/jenkins_home/jobs/" \
        -v "${PWD}/m2deps:/var/jenkins_home/.m2/repository/" \
        -v "${HOME}/.ssh:/var/jenkins_home/.ssh/" \
        --rm -d --name ${container_name} \
        ${dockerhub_user}/${image_name}:${image_version}
    docker ps && xdg-open http://localhost:8080
}



# ---------- PREPARING ALL ----------
function prepareK8s() {
    createCluster
    creteServiceAccount
    creteRoleBinding
    getServiceAccountToken
}
function prepareWorkspace() {
    cleanBuildWorkspace "${folders[@]}"
    getTools
}
function prepareAll() {
    prepareWorkspace
    prepareK8s
    buildJenkinsContainerImage
}
function showManual() {
    echo "
    DESCRIPTION: Script to setup Jenkins.
    USE: jks [OPTION]
        jks init
        jks up
        jks down

    OPCOES:
        -i, init    Make a Minikube Cluster and build Jenkins container image
        -u, up      Set the workspace and run Jenkins
        -d, down    Remove jenkins container and clean the workspace
        -h, help    Show this manual
        -c, clean   Clean Workspace"
}


# ---------- MAIN ----------
case $1 in
    '-i'|'init')   prepareAll                       ;;
    '-u'|'up')     runJenkinsContainer              ;;
    '-d'|'down')   deleteJenkinsContainer           ;;
    '-h'|'help')   showManual                       ;;
    '-c'|'clean')  cleanBuildWorkspace              ;;
    *) echo "[ERROR] Invalid Option"; showManual    ;;
esac