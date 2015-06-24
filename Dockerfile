FROM mkaag/baseimage:latest
MAINTAINER Maurice Kaag <mkaag@me.com>

# -----------------------------------------------------------------------------
# Environment variables
# -----------------------------------------------------------------------------
ENV ES_VERSION    1.6.0
ENV JAVA_VERSION  8

# -----------------------------------------------------------------------------
# Pre-install
# -----------------------------------------------------------------------------
RUN \
  echo oracle-java$JAVA_VERSION-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update -qqy && \
  apt-get install -qqy oracle-java$JAVA_VERSION-installer && \
  rm -rf /var/cache/oracle-jdk$JAVA_VERSION-installer
ENV JAVA_HOME /usr/lib/jvm/java-$JAVA_VERSION-oracle

# -----------------------------------------------------------------------------
# Install
# -----------------------------------------------------------------------------
WORKDIR /opt
RUN \
  wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ES_VERSION.tar.gz && \
  tar xvzf elasticsearch-$ES_VERSION.tar.gz && \
  rm -f elasticsearch-$ES_VERSION.tar.gz && \
  ln -s /opt/elasticsearch-$ES_VERSION /opt/elasticsearch

# -----------------------------------------------------------------------------
# Post-install
# -----------------------------------------------------------------------------
ADD build/elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml
ADD build/logging.yml /opt/elasticsearch/config/logging.yml

RUN \
  elasticsearch/bin/plugin -i lmenezes/elasticsearch-kopf && \
  elasticsearch/bin/plugin -i elasticsearch/marvel/latest && \
  elasticsearch/bin/plugin -i mobz/elasticsearch-head

RUN mkdir /etc/service/elasticsearch
ADD build/elasticsearch.sh /etc/service/elasticsearch/run
RUN chmod +x /etc/service/elasticsearch/run

EXPOSE 9200 9300
VOLUME ["/data"]

CMD ["/sbin/my_init"]

# -----------------------------------------------------------------------------
# Clean up
# -----------------------------------------------------------------------------
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
