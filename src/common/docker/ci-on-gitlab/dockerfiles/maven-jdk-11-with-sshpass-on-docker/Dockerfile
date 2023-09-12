FROM maven:3.9.3-amazoncorretto-11-debian

# RUN echo "Acquire::http::proxy \"http://26.247.64.251:3128\";\nAcquire::https::proxy \"http://26.247.64.251:3128\";" > /etc/apt/apt.conf

RUN apt-get update && apt-get install -y locales sshpass nodejs \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*
RUN sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen \
&& locale-gen
ENV LANG ja_JP.UTF-8