## Scripts úteis

### Baixando o jenkins-cli
```
curl 'localhost:8080/jnlpJars/jenkins-cli.jar' > jenkins-cli.jar
```

### Script para rodar fora do jenkins: jenkins-cli.jar
``` groovy
def plugins = jenkins.model.Jenkins.instance.getPluginManager().getPlugins()
plugins.each {println "${it.getShortName()}: ${it.getVersion()}"}
```

### Obtentdo informações de plugins via jenkins-cli
``` shell
java -jar jenkins-cli.jar -s http://localhost:8080 groovy --username "jenkins" --password "jenkins" = < plugins.groovy > plugins.list
```

### Script para rodar dentro jenkins para coletar os plugins disponíveis e suas respectivas versões
``` groovy
Jenkins.instance.pluginManager.plugins.each{
  plugin -> 
    println ("${plugin.getShortName()}:${plugin.getVersion()}")
}
```

