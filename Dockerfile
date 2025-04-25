# Use Ubuntu 22.04 as base
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    CATALINA_HOME=/opt/tomcat \
    PATH=$JAVA_HOME/bin:$CATALINA_HOME/bin:$PATH \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=UTC

# Configure timezone and install dependencies
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    maven \
    wget \
    curl \
    git \
    mysql-server \
    && rm -rf /var/lib/apt/lists/* && \
    update-alternatives --set java $JAVA_HOME/bin/java && \
    update-alternatives --set javac $JAVA_HOME/bin/javac

# Install Tomcat
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.28/bin/apache-tomcat-10.1.28.tar.gz -O /tmp/tomcat.tar.gz && \
    tar -xzf /tmp/tomcat.tar.gz -C /opt && \
    mv /opt/apache-tomcat-10.1.28 /opt/tomcat && \
    rm /tmp/tomcat.tar.gz && \
    chmod +x /opt/tomcat/bin/*.sh

# Configure MySQL
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql && \
    chmod -R 755 /var/run/mysqld

# Working directory
WORKDIR /app

# Copy application files
COPY spring-app/pom.xml /app/spring-app/pom.xml
COPY spring-app/src /app/spring-app/src
COPY frontend/dist /opt/tomcat/webapps/ROOT

# Build application (with cache optimization)
RUN cd /app/spring-app && \
    mvn dependency:go-offline && \
    mvn clean package && \
    cp target/spring-app.war /opt/tomcat/webapps/

# Expose ports
EXPOSE 8080 3306

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]