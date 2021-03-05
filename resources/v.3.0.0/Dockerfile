FROM jenkins/jenkins:2.263.4

LABEL Author="Augusto Cardoso dos Santos" 

ARG KUBERNETES_SERVER_URL
ARG JENKINS_SERVER_URL
ARG K8S_KEY
ARG MASTER_IMAGE_VERSION="v.3.0.0"

ENV master_image_version = ${MASTER_IMAGE_VERSION}
ENV KUBERNETES_SERVER_URL = ${KUBERNETES_SERVER_URL}
ENV JENKINS_SERVER_URL = ${JENKINS_SERVER_URL}
ENV K8S_KEY = ${K8S_KEY}

USER root
# RUN chown -R jenkins:jenkins /var/jenkins_home
# USER jenkins

COPY downloads/*.tar.gz /var/jenkins_home/downloads/
COPY plugins.list /usr/share/jenkins/ref/plugins.list

RUN echo 2.112 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state \
    echo 2.112 > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.list

COPY src/main/groovy/* /usr/share/jenkins/ref/init.groovy.d/
COPY src/main/resources/*.properties /var/jenkins_home/config/
COPY src/main/resources/initials/*.file /var/jenkins_home/config/initials/

COPY .ssh/* /var/jenkins_home/.ssh/
