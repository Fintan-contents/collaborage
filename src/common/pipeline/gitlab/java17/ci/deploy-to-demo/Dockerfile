FROM openjdk:17.0.2-jdk-buster
COPY . /usr/src/app
WORKDIR /usr/src/app
EXPOSE 3333
CMD java -jar $(find . -name *standalone.jar) -d webapp/ -p 3333
