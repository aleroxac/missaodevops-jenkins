## Dependências para o projeto


## AWS e Ansible
``` shell
### python e pip
sudo apt install -y python3 python3-pip         # debian
sudo yum install -y python3 python3-pip         # redhat
sudo pacman -S --no-confirm python3 python3-pip # archlinux
sudo apk add python3 py3-pip                    # alpine

### awscli e ansible
sudo pip3 install boto3 awscli ansible
```


## Docker
``` shell
### Instalando o curl
sudo apt install -y curl            # debian
sudo yum install -y curl            # redhat
sudo pacman -S --no-confirm curl    # archlinux
sudo apk add curl                   # alpine

#### Baixando e instalando o docker
curl -fsSL https://get.docker.com.br | sh

#### Depois de rodar o comando abaixo, faça logout e login, ou reboot, para conseguir usar o docker sem sudo
sudo usermod -aG docker ${USERNAME} 
sudo systemctl enable docker
reboots
```

## Terraform e Packer
``` shell
### Instalando o unzip e wget
sudo apt install -y unzip wget            # debian
sudo yum install -y unzip wget            # redhat
sudo pacman -S --no-confirm unzip wget    # archlinux
sudo apk add unzip wget                   # alpine

### Baixando e instalando o Packer
wget -P /tmp "https://releases.hashicorp.com/packer/1.6.5/packer_1.6.5_linux_amd64.zip"
unzip /tmp/packer*.zip
sudo mv /tmp/packer /usr/local/bin/

### Baixando e instalando o Terraform
wget -P /tmp "https://releases.hashicorp.com/terraform/0.14.6/terraform_0.14.6_linux_amd64.zip"
unzip /tmp/terraform*.zip
sudo mv /tmp/terraform /usr/local/bin/
```


## Fazendo tudo isso de uma vez só
``` shell
### Instalando pacotes necessários
sudo apt install -y python3 python3-pip curl unzip wget 

### Instalando bibliotecas necessárias
sudo pip3 install boto3 awscli ansible

### Instalando o Docker
curl -fsSL https://get.docker.com.br | sh
sudo usermod -aG docker ${USERNAME}
sudo systemctl enable docker
reboot

### Instalando o Packer e Terraform
wget -P /tmp "https://releases.hashicorp.com/packer/1.6.5/packer_1.6.5_linux_amd64.zip"
wget -P /tmp "https://releases.hashicorp.com/terraform/0.14.6/terraform_0.14.6_linux_amd64.zip"
unzip /tmp/*.zip
sudo mv /tmp/packer /usr/local/bin/
sudo mv /tmp/terraform /usr/local/bin/
```