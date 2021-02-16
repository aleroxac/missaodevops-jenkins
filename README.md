## missaodevops-jenkins
![missaodevops-jenkins](http://missaodevops.com.br/img/jenkins/missaodevops-jenkins-docker-kube.png)
Projeto desenvolvido durante treinamento "Jenkins em larga escala com Docker e Kubernetes" da Missão DevOps.


## Recursos
- AWS: Cloud escolhida
- Jenkins: Para rodar nossos pipelines
- Docker: Para rodar nossos containers
- Kubernetes: Para orquestrar nossos containers
- Packer: Para gerar nossas AMIs para instâncias
- Ansible: Para provisionar nossas instâncias
- Terraform: Para subir a infraestrutura necessária


## Dependências
- Conta na AWS
- Conta no Github
- Acesso a um emulador de terminal com um Shell Linux, como o Bash, por exemplo


## Configuração do projeto
- [Crie uma conta na AWS](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
- [Crie uma conta no Github](https://docs.github.com/en/github/getting-started-with-github/signing-up-for-a-new-github-account)
- Se estiver no Windows, baixe e instale o [git-bash](https://git-scm.com/download/win)
- Baixe este [repositório](https://github.com/aleroxac/missaodevops-jenkins/archive/master.zip)
- [Instale as dependências](docs/REQUIREMENTS.md) para o projeto
- [Construa uma AMI customizada](docs/BUILD_AMI.md) com Packer e Ansible
- [Suba uma instância EC2](LAUNCH_EC2.md) com o Terraform


## Observações
Durante a implementação do projeto resolvi utilizar algumas ferramentas que não estão na proposta do treinamento, mas como preciso evoluir nelas, achei uma boa ideia aproveitar a situação para utilizá-las.


## Página do projeto do treinamento
http://missaodevops.com.br/docs/jenkins_home.html




## Scripts úteis
``` md
### Baixando o jenkins-cli
``` shell
curl 'localhost:8080/jnlpJars/jenkins-cli.jar' > jenkins-cli.jar
```

### script para rodar fora do jenkins
``` groovy
def plugins = jenkins.model.Jenkins.instance.getPluginManager().getPlugins()
plugins.each {println "${it.getShortName()}: ${it.getVersion()}"}
```

### obetentdo informações de plugins via jenkins-cli
``` shell
java -jar jenkins-cli.jar -s http://localhost:8080 groovy --username "jenkins" --password "jenkins" = < plugins.groovy > plugins.list
```




### script para rodar dentro jenkins
``` groovy
Jenkins.instance.pluginManager.plugins.each{
  plugin -> 
    println ("${plugin.getShortName()}:${plugin.getVersion()}")
}
```

### gerando certificado do cluster k8s do minikube
kubectl create namespace jenkins && kubectl create serviceaccount jenkins --namespace=jenkins && kubectl describe secret $(kubectl describe serviceaccount jenkins --namespace=jenkins | grep Token | awk '{print $2}') --namespace=jenkins && kubectl create rolebinding jenkins-admin-binding --clusterrole=admin --serviceaccount=jenkins:jenkins --namespace=jenkins

```