import jenkins.model.Jenkins
import org.csanchez.jenkins.plugins.kubernetes.ContainerTemplate
import org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud
import org.csanchez.jenkins.plugins.kubernetes.PodTemplate

println "\n############################ KUBERNETES CLOUDs SETUP ############################"

if( ! System.getenv().containsKey('KUBERNETES_SERVER_URL') ) {
    println(">>> Evironment Variable 'KUBERNETES_SERVER_URL' not found")
    println(">>> Please set them before start Jenkins")
    return
}

def jenkins = Jenkins.getInstanceOrNull()
def cloudList = jenkins.clouds

def home_dir = System.getenv("JENKINS_HOME")
def properties = new ConfigSlurper().parse(new File("$home_dir/config/clouds.properties").toURI().toURL())

properties.kubernetes.each { cloudKubernetes ->
    println ">>> Kubernetes Cloud Setting up: " + cloudKubernetes.value.get('name')

    List<PodTemplate> podTemplateList = new ArrayList<PodTemplate>()
    cloudKubernetes.value.get('pods').each { podTemplate ->
        println ">>>>>> POD Template setup: " + podTemplate.value.get('name')
        def newPodTemplate = createBasicPODTemplate(podTemplate)

        List<ContainerTemplate> containerTemplateList = new ArrayList<ContainerTemplate>()
        podTemplate.value.get('containers').each { containerTemplate ->
            println ">>>>>>>>> Container Template setup: " + containerTemplate.value.get('name')
            containerTemplateList.add( createBasicContainerTemplate(containerTemplate) )
        }

        newPodTemplate.setContainers(containerTemplateList)
        podTemplateList.add(newPodTemplate)
    }
    def kubernetesCloud = createKubernetesCloud(cloudKubernetes, podTemplateList)
    cloudList.replace(kubernetesCloud)
}
jenkins.save()
println("Clouds Adicionadas: " + Jenkins.getInstanceOrNull().clouds.size())


def createKubernetesCloud(cloudKubernetes, podTemplateList) {
    def serverUrl = System.getenv("KUBERNETES_SERVER_URL")
    def jenkinsUrl = System.getenv("JENKINS_SERVER_URL")
    def kubernetesCloud = new KubernetesCloud(
            cloudKubernetes.value.get('name'),
            podTemplateList,
            serverUrl,
            cloudKubernetes.value.get('namespace'),
            jenkinsUrl,
            cloudKubernetes.value.get('containerCapStr'),
            cloudKubernetes.value.get('connectionTimeout'),
            cloudKubernetes.value.get('readTimeout'),
            cloudKubernetes.value.get('retentionTimeout')
    )
    kubernetesCloud.setSkipTlsVerify(cloudKubernetes.value.get('skipTlsVerify', true))
    kubernetesCloud.setCredentialsId(cloudKubernetes.value.get('credentialsId'))
    kubernetesCloud.setWaitForPodSec(cloudKubernetes.value.get('waitForPodSec'))
    kubernetesCloud.setMaxRequestsPerHost(cloudKubernetes.value.get('maxRequestsPerHost'))
    kubernetesCloud.setLabels("jenkins":"worker")
    return kubernetesCloud;
}

def createBasicPODTemplate(podTemplate) {
    PodTemplate basicPodTemplate = new PodTemplate()
    basicPodTemplate.setName(podTemplate.value.get('name'))
    basicPodTemplate.setNamespace(podTemplate.value.get('namespace'))
    basicPodTemplate.setLabel(podTemplate.value.get('label'))
    basicPodTemplate.setSlaveConnectTimeout(podTemplate.value.get('slaveConnectTimeout'))
    basicPodTemplate.setInstanceCapStr(podTemplate.value.get('instanceCapStr'))
    basicPodTemplate.setIdleMinutesStr(podTemplate.value.get('idleMinutesStr'))
    return basicPodTemplate;
}

def createBasicContainerTemplate(containerTemplate) {
    ContainerTemplate basicContainerTemplate = new ContainerTemplate(
            containerTemplate.value.get('name'),
            containerTemplate.value.get('image'),
            containerTemplate.value.get('command'),
            containerTemplate.value.get('args')
    )
    basicContainerTemplate.setTtyEnabled(containerTemplate.value.get('ttyEnabled', true))
    basicContainerTemplate.setWorkingDir(containerTemplate.value.get('workingDir'))
    return basicContainerTemplate;
}