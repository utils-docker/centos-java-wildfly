FROM fabioluciano/centos-base-java
MAINTAINER Fábio Luciano <fabio@naoimporta.com>
LABEL Description="CentOS Java Wildfly"

ARG wildfly_version
ENV wildfly_version ${wildfly_version:-"8.2.1.Final"}

ARG wildfly_username
ENV wildfly_username ${wildfly_username:-"wildfly"}

ARG wildfly_password
ENV wildfly_password ${wildfly_password:-"password"}

ARG install_dir
ENV install_dir ${install_dir:-"/opt"}

ENV wildfly_url "http://download.jboss.org/wildfly/${wildfly_version}/wildfly-${wildfly_version}.tar.gz"

WORKDIR ${install_dir}

COPY configurations/supervisor.d/* /etc/supervisor.d/
COPY configurations/scripts/entrypoint.sh /usr/local/bin

RUN yum -y update && yum install -y openssh-server \
  && printf "${wildfly_password}\n${wildfly_password}" | adduser ${wildfly_username} \
  && echo "${wildfly_username}:${wildfly_password}" | chpasswd \
  && ssh-keygen -q -t rsa -f /etc/ssh/ssh_host_rsa_key -P "" \
  && ssh-keygen -q -t dsa -f /etc/ssh/ssh_host_dsa_key -P "" \
  && ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -P ""\
  && ssh-keygen -q -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -P "" \
  && echo "AllowUsers ${wildfly_username}" >> /etc/ssh/sshd_config \
  && curl -L ${wildfly_url} > wildfly.tar.gz && directory=$(tar tfz wildfly.tar.gz --exclude '*/*') \
  && tar -xzf wildfly.tar.gz && rm wildfly.tar.gz && mv $directory wildfly \
  && echo 'JAVA_OPTS="$JAVA_OPTS -Duser.timezone=America/Sao_Paulo -Duser.country=BR -Duser.language=pt"' >> /opt/wildfly/bin/standalone.conf \
  && chown ${wildfly_username}:${wildfly_username} /opt/wildfly -R \
  && /opt/wildfly/bin/add-user.sh admin admin --silent=true \
  && chmod a+x /usr/local/bin/ -R \
  && yum clean all && rm -rf /tmp/*

WORKDIR ${install_dir}/wildfly

VOLUME ["/opt/wildfly/standalone/deployments/", "/opt/wildfly/standalone/tmp/", "/opt/wildfly/standalone/data/", "/opt/wildfly/standalone/log/"]

EXPOSE 22/tcp 8080/tcp 8443/tcp 9990/tcp
