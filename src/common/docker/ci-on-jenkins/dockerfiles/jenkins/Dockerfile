FROM jenkins/jenkins:2.190.3

USER root

RUN echo "Acquire::http::proxy \"$http_proxy\";\nAcquire::https::proxy \"$https_proxy\";" > /etc/apt/apt.conf

RUN apt-get update -y \
&& apt-get -y install sshpass

USER jenkins