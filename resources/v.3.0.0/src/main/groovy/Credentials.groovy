import java.lang.System
import jenkins.*
import hudson.model.*
import jenkins.model.*

import static com.cloudbees.plugins.credentials.CredentialsScope.GLOBAL
import hudson.plugins.sshslaves.*
import hudson.util.Secret
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.SystemCredentialsProvider
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import com.cloudbees.plugins.credentials.CredentialsStore
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import org.jenkinsci.plugins.plaincredentials.*

// Read properties
def home_dir = System.getenv("JENKINS_HOME")
def properties = new ConfigSlurper().parse(new File("$home_dir/config/credentials.properties").toURI().toURL())

global_domain = Domain.global()
credentials_store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

println "\n############################ STARTING CREDENTIALS CONFIG ############################"

properties.credentials.each {
  switch (it.value.type) {
    case "ssh":
      if (! new File(it.value.path).exists()) {
        throw new FileNotFoundException("${it.value.path} doesn't exists! Check credentials configuration")
      }
      println ">>> Create credentials for user ${it.value.userId} by SSH private key ${it.value.path}"
      creds = new BasicSSHUserPrivateKey(
        GLOBAL,
        it.value.credentialsId,
        it.value.userId,
        new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource(it.value.path),
        it.value.passphrase,
        it.value.description
      )
      credentials_store.addCredentials(global_domain, creds)
      break
    case "password":
      if (! new File(it.value.path).exists()) {
        throw new FileNotFoundException("${it.value.path} doesn't exists! Check credentials configuration")
      }
      println ">>> Create credentials for user ${it.value.userId} by password from ${it.value.path}"
      creds = new UsernamePasswordCredentialsImpl(
        GLOBAL,
        it.value.credentialsId,
        it.value.description,
        it.value.userId,
        new File(it.value.path).text.trim()
      )
      credentials_store.addCredentials(global_domain, creds)
      break
    case "string":
      def k8s_key = System.getenv("K8S_KEY")
      println ">>> Create credentials for serviceaccount key kubernetes cluster by K8S_KEY environment variable"
      creds = new StringCredentialsImpl(
        GLOBAL,
        it.value.id,
        it.value.description,
        Secret.fromString(k8s_key)
      )
      credentials_store.addCredentials(global_domain, creds)
      break
    default:
      throw new UnsupportedOperationException("${it.value.type} credentials type is not supported!")
      break
  }
}