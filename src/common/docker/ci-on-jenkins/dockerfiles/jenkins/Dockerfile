FROM jenkins/jenkins:2.401.1

USER root

RUN echo "Acquire::http::proxy \"$http_proxy\";\nAcquire::https::proxy \"$https_proxy\";" > /etc/apt/apt.conf

RUN apt-get update -y \
&& apt-get install -y locales sshpass \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*
RUN sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen \
&& locale-gen
ENV LANG ja_JP.UTF-8

USER jenkins