FROM maven:3.6.2-jdk-8

# RUN echo "Acquire::http::proxy \"http://26.247.64.251:3128\";\nAcquire::https::proxy \"http://26.247.64.251:3128\";" > /etc/apt/apt.conf

RUN apt-get update -y \
&& apt-get -y install sshpass