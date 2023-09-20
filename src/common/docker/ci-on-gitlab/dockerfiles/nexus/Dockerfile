FROM sonatype/nexus3:3.55.0

USER root

RUN /usr/bin/keytool -keystore /opt/sonatype/nexus/etc/ssl/keystore.jks -alias jetty \
-genkey -keyalg RSA -sigalg SHA256withRSA \
-storepass password -keypass password \
-validity 7300 \
-dname "CN=dummy, OU=dummy, O=dummy, L=dummy, ST=dummy, C=dummy" \
&& echo "application-port-ssl=8443" >> /opt/sonatype/nexus/etc/nexus-default.properties \
&& sed -i -e 's/jetty-http\.xml,/jetty-http\.xml,\$\{jetty\.etc\}\/jetty-https\.xml,/' /opt/sonatype/nexus/etc/nexus-default.properties \
&& sed -i -e 's/<Set name="KeyStorePassword">.*$/<Set name="KeyStorePassword">password<\/Set>/' /opt/sonatype/nexus/etc/jetty/jetty-https.xml \
&& sed -i -e 's/<Set name="KeyManagerPassword">.*$/<Set name="KeyManagerPassword">password<\/Set>/' /opt/sonatype/nexus/etc/jetty/jetty-https.xml \
&& sed -i -e 's/<Set name="TrustStorePassword">.*$/<Set name="TrustStorePassword">password<\/Set>/' /opt/sonatype/nexus/etc/jetty/jetty-https.xml

EXPOSE 8443

USER nexus
