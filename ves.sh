#!/bin/bash

# Get OS type
case "$OSTYPE" in
  solaris*) OS="SOLARIS" ;;
  darwin*)  OS="OSX" ;;
  linux*)   OS="LINUX" ;;
  bsd*)     OS="BSD" ;;
  msys*)    OS="WINDOWS" ;;
  cygwin*)  OS="ALSO WINDOWS" ;;
  *)        OS="unknown: $OSTYPE" ;;
esac

# Get OS distribution
if [ "$OS" == "LINUX" ]
  then
  DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
else
  DISTRO="$OS"
fi

# Functions
docker_install() {
  EXISTING="$(docker -v)"
  if [ "$DISTRO" == "\"Ubuntu\"" ] && [ -z "$EXISTING" ]
    then
    docker_ubuntu_install
    echo "Docker was successfully installed!"
  elif [ "$DISTRO" == "\"CentOS\"" ] && [ -z "$EXISTING" ]
    then
    docker_centos_install
    echo "Docker was successfully installed!"
  elif [ "$DISTRO" == "\"Debian\"" ] && [ -z "$EXISTING" ]
    then
    docker_debian_install
    echo "Docker was successfully installed!"
  elif [ "$EXISTING" ]
    then
    echo "Docker is already installed!"
  else
    echo "Unsupported OS: $OS | Release: $DISTRO"
  fi
  unset $EXISTING
}

docker_ubuntu_install() {
  apt-get update -y && apt-get install ca-certificates curl gnupg -y
  install -m 0755 -d /etc/apt/keyrings
  -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  usermod -a -G docker $USER
  echo "Docker installed successfully!"
  echo "You can use Docker and docker-compose/docker compose"
}

docker_centos_install() {
  yum install -y yum-utils curl
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl start docker
  curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  usermod -a -G docker $USER
  echo "Docker installed successfully!"
  echo "You can use Docker and docker-compose/docker compose"
}

docker_debian_install() {
  apt-get update -y && apt-get install ca-certificates curl gnupg -y
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  usermod -a -G docker $USER
  echo "Docker installed successfully!"
  echo "You can use Docker and docker-compose/docker compose"
}

minikube_install() {
  EXISTING="$(minikube version --short)"
  if [ "$DISTRO" == "\"Ubuntu\"" ] && [ -z "$EXISTING" ]
    then
    minikube_ubuntu_install
    echo "Minikube was successfully installed!"
    echo "In order to start minikube run:"
    echo "minikube start"
  elif [ "$DISTRO" == "\"CentOS\"" ] && [ -z "$EXISTING" ]
    then
    minikube_centos_install
    echo "Minikube was successfully installed!"
  elif [ "$DISTRO" == "\"Debian\"" ] && [ -z "$EXISTING" ]
    then
    minikube_debian_install
    echo "Minikube was successfully installed!"
    echo "In order to start minikube run:"
    echo "minikube start"
  elif [ "$EXISTING" ]
    then
    echo "Minikube is already installed!"
  else
    echo "Unsupported OS: $OS | Release: $DISTRO"
  fi
  unset $EXISTING
}

minikube_ubuntu_install() {
  apt-get update -y && apt-get upgrade -y
  wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  chmod +x minikube-linux-amd64
  mv minikube-linux-amd64 /usr/local/bin/minikube
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  mv ./kubectl /usr/local/bin/kubectl
}

minikube_debian_install() {
  apt update -y && apt upgrade -y
  apt install curl wget apt-transport-https -y
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  install minikube-linux-amd64 /usr/local/bin/minikube
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x ./kubectl
  mv kubectl /usr/local/bin/
}

minikube_centos_install() {
  echo "[kubernetes]" >> /etc/yum.repos.d/kubernetes.repo
  echo "name=Kubernetes" >> /etc/yum.repos.d/kubernetes.repo
  echo "baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64" >> /etc/yum.repos.d/kubernetes.repo
  echo "enabled=1" >> /etc/yum.repos.d/kubernetes.repo
  echo "gpgcheck=1" >> /etc/yum.repos.d/kubernetes.repo
  echo "repo_gpgcheck=1" >> /etc/yum.repos.d/kubernetes.repo
  echo "gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg" >> /etc/yum.repos.d/kubernetes.repo
  echo "https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" >> /etc/yum.repos.d/kubernetes.repo
  yum install -y kubelet
  yum install -y kubeadm
}

terraform_install() {
  EXISTING="$(terraform --version)"
  if [ "$DISTRO" == "\"Ubuntu\"" ] && [ -z "$EXISTING" ]
    then
    terraform_ubuntu_install
    echo "Terraform was successfully installed!"
  elif [ "$DISTRO" == "\"CentOS\"" ] && [ -z "$EXISTING" ]
    then
    terraform_centos_install
    echo "Terraform was successfully installed!"
  elif [ "$DISTRO" == "\"Debian\"" ] && [ -z "$EXISTING" ]
    then
    terraform_debian_install
    echo "Terraform was successfully installed!"
  elif [ "$EXISTING" ]
    then
    echo "Terraform is already installed!"
  else
    echo "Unsupported OS: $OS | Release: $DISTRO"
  fi
  unset $EXISTING
}

terraform_ubuntu_install() {
  apt update && apt install  software-properties-common gnupg2 curl -y
  curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > hashicorp.gpg
  install -o root -g root -m 644 hashicorp.gpg /etc/apt/trusted.gpg.d/
  apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  apt update && apt install terraform
}

terraform_debian_install() {
  apt-get install wget curl unzip software-properties-common gnupg2 -y
  curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
  apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  apt-get update -y
  apt-get install terraform -y
}

installation() {
  if [ "$ARG2" == "docker" ]
    then
    docker_install
  elif [ "$ARG2" == "minikube" ]
    then
    minikube_install
  elif [ "$ARG2" == "terraform" ]
    then
    terraform_install
  elif [ "$ARG2" == "all" ]
    then
    docker_install
    minikube_install
    terraform_install
  else
    echo " "
    echo "No Application chosen (ves install APP)"
    echo "Please choose what to install:"
    echo "Docker (docker)"
    echo "Minikube (minkube)"
    echo "Terraform (terraform)"
    echo "All (all)"
  fi
}

ip_addresses() {
  EXTERNAL_IP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
  INTERNAL_IP="$(hostname -I)"
  echo "Public IP: $EXTERNAL_IP"
  echo "Private IP: $INTERNAL_IP"
}

core_load(){
  EXISTING="$(sensors -v)"
  if [ -z "$EXISTING" ]
    then
    apt install sensors
  fi
  LOAD="$(__=`sensors | grep Core` && echo \(`echo $__ | sed 's/.*+\(.*\).C\(\s\)\+(.*/\1/g' | tr "\n" "+" | head -c-1`\)\/`echo $__ | wc -l` | bc && unset __)"
  echo "Average CPU load: $LOAD%"
}

html_info() {
  lshw -html 2> /dev/null > pc-info.html
  echo "An html file has been generated with additional pc information, open in browser to see"
}

space_usage() {
  DISK_USAGE="$(df -h /)"
  echo "Disk usage:"
  echo "$DISK_USAGE"
}

# Listen for the command
COMMAND="$1"
ARG2="$2"

# If the command is "install"
if [ "$COMMAND" == "install" ]
  then
  installation
elif [ "$COMMAND" == "pcinfo" ]
  then
  echo " "
  echo "Showing PC Information"
  echo " "
  echo "OS: $OS"
  echo "Release: $DISTRO"
  echo " "
  ip_addresses
  echo " "
  core_load
  echo " "
  html_info
else
  echo " "
  echo "+=======================================================================+"
  echo "+                               USAGE                                   +"
  echo "+                                                                       +"
  echo "+                                                                       +"
  echo "+ ves install          -- Will show you what applications are available +"
  echo "+ ves pcinfo           -- Will give you information about the PC        +"
  echo "+=======================================================================+"
fi