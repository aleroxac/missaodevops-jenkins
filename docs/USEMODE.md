# Modo de uso

## O. Faça o Setup inicial
- [Crie uma conta na AWS](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
- [Crie uma conta no Github](https://docs.github.com/en/github/getting-started-with-github/signing-up-for-a-new-github-account)
- Se estiver no Windows, baixe e instale o [git-bash](https://git-scm.com/download/win)
- Baixe este [repositório](https://github.com/aleroxac/missaodevops-jenkins/archive/master.zip)


## 1. Instale o Docker
``` shell
### Instalando o curl
sudo apt install -y curl

### Baixando e instalando o docker
curl -fsSL https://get.docker.com.br | sh

### Depois de rodar o comando abaixo, faça logout e login, ou reboot, para conseguir usar o docker sem sudo
sudo usermod -aG docker ${USERNAME}
sudo systemctl enable docker
reboot
```


## 2. Instale o kubectl
``` shell
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```


## 3. Instale o minikube
``` shell
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

## 5. Entre na pasta da versão que deseja testar e rode o script para preparar o ambiente, buildar e subir o container do Jenkins
``` shell
## Tive vários problemas para fazer os scripts groovy das credenciais e do k8s-cloud funcinarem, acabei não voltando para arrumar as versões anteriores.
## A versão v3.0.0 foi a que mais mexi, ela está 100%. Das versões v.1.0.0 a v.2.2.1 ainda preciso revisar
cd resources/v.3.0.0
alias jks="./jks.sh"
jks init && jks up
```
