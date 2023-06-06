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
  apt-get update -y && apt-get install ca-certificates curl gnupg -y 2>/dev/null
  install -m 0755 -d /etc/apt/keyrings 2>/dev/null
  -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null
  chmod a+r /etc/apt/keyrings/docker.gpg 2>/dev/null
  echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list 2>/dev/null
  apt-get update && apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y 2>/dev/null
  curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose 2>/dev/null
  chmod +x /usr/local/bin/docker-compose 2>/dev/null
  usermod -a -G docker $USER 2>/dev/null
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
  apt-get update -y && apt-get upgrade -y 2>/dev/null
  wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 2>/dev/null
  chmod +x minikube-linux-amd64 2>/dev/null
  mv minikube-linux-amd64 /usr/local/bin/minikube 2>/dev/null
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl 2>/dev/null
  chmod +x ./kubectl 2>/dev/null
  mv ./kubectl /usr/local/bin/kubectl 2>/dev/null
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
    apt install lm-sensors
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

update_script() {
  curl https://raw.githubusercontent.com/Vesves4/ves/main/ves.sh > /home/$USER/ves/ves-tmp.sh 2>/dev/null
  DIFF_PRESENT="$(diff -v)"
  if [ -z "$DIFF_PRESENT" ] && [ "$DISTRO" == "\"Ubuntu\"" ]
    then
    apt-install diff
  fi
  DIFF_FILE="$(diff /home/$USER/ves/ves.sh /home/$USER/ves/ves-tmp.sh)"
  if [ -z "$DIFF_FILE" ]
    then
    rm /home/$USER/ves/ves-tmp.sh
    echo "There is no update available!"
  elif [ "$DIFF_FILE" ]
    then
    rm /home/$USER/ves/ves.sh
    mv /home/$USER/ves/ves-tmp.sh /home/$USER/ves/ves.sh
    chmod +x /home/$USER/ves/ves.sh
    echo "Script was updated!"
  else
    echo "Unrecognized error.."
  fi
}

configure_functions() {
  if [ "$ARG2" == "alias" ]
    then
    function_alias
  elif [ "$ARG2" == "gui" ]
    then
    function_gui
  fi
}

function_alias() {
  if [ "$COMMAND" == "add" ]
    then
    add_custom_aliases
  elif [ "$COMMAND" == "remove" ]
    then
    remove_custom_aliases
  else
    echo "Alias error"
  fi
}

add_custom_aliases() {
  ALIAS_FILE=$(cat /home/$USER/ves/aliases/aliases.ves 2>/dev/null)
  ALIAS_COMMAND=$(cat /home/$USER/.bashrc | grep aliases.ves 2>/dev/null)
  if [ -z "$ALIAS_FILE" ] && [ -z "$ALIAS_COMMAND" ]
    then
    curl URL > /home/$USER/ves/aliases/aliases.ves
    echo ". ~/ves/aliases/aliases.ves" >> /home/$USER/.bashrc
  elif [ -z "$ALIAS_FILE" ] && [ "$ALIAS_COMMAND" ]
    then
    curl URL > /home/$USER/ves/aliases/aliases.ves
  elif [ "$ALIAS_FILE" ] && [ -z "$ALIAS_COMMAND" ]
    then
    curl URL > /home/$USER/ves/aliases/aliases.ves
    echo ". ~/ves/aliases/aliases.ves" >> /home/$USER/.bashrc
  elif [ "$ALIAS_FILE" ] && [ "$ALIAS_COMMAND" ]
    then
    echo "Aliases are already setup"
  else
    echo "Alias installation error"
  fi
}

remove_custom_aliases() {
  ALIAS_FILE=$(cat /home/$USER/ves/aliases/aliases.ves 2>/dev/null)
  ALIAS_COMMAND=$(cat /home/$USER/.bashrc | grep aliases.ves 2>/dev/null)
  if [ -z "$ALIAS_FILE" ] && [ -z "$ALIAS_COMMAND" ]
    then
    echo "There's nothing to remove!"
  elif [ -z "$ALIAS_FILE" ] && [ "$ALIAS_COMMAND" ]
    then
    sed -i 's%. ~/ves/aliases/aliases.ves%%' /home/$USER/.bashrc 
  elif [ "$ALIAS_FILE" ] && [ -z "$ALIAS_COMMAND" ]
    then
    rm /home/$USER/ves/aliases/aliases.ves
  elif [ "$ALIAS_FILE" ] && [ "$ALIAS_COMMAND" ]
    then
    sed -i 's%. ~/ves/aliases/aliases.ves%%' /home/$USER/.bashrc
    rm /home/$USER/ves/aliases/aliases.ves
  else
    echo "Alias removal error"
  fi
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
elif [ "$COMMAND" == "update" ]
  then
  update_script
elif [ "$COMMAND" == "add" ] || [ "$COMMAND" == "remove" ]
  then
  configure_functions
else
  clear
  echo "+==========================================================================+"
  echo "+                               USAGE                                      +"
  echo "+                                                                          +"
  echo "+                                                                          +"
  echo "+ ves install          -- Will show you what applications are available    +"
  echo "+ ves pcinfo           -- Will give you information about the PC           +"
  echo "+ ves update           -- Will update the script to its newest version     +"
  echo "+ ves add              -- Will show you a list of functions u can add      +"
  echo "+ ves remove           -- Will show you a list of functions you can remove +"
  echo "+==========================================================================+"
fi
