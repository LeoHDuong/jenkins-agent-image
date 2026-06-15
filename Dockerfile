FROM jenkins/inbound-agent:latest

USER root

# System dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    curl \
    wget \
    git \
    unzip \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Gitleaks
RUN wget https://github.com/gitleaks/gitleaks/releases/download/v8.18.4/gitleaks_8.18.4_linux_x64.tar.gz \
    && tar -xzf gitleaks_8.18.4_linux_x64.tar.gz \
    && mv gitleaks /usr/local/bin/ \
    && rm gitleaks_8.18.4_linux_x64.tar.gz

# Sonar Scanner
RUN wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip \
    && unzip sonar-scanner-cli-5.0.1.3006-linux.zip \
    && mv sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner \
    && ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner \
    && rm sonar-scanner-cli-5.0.1.3006-linux.zip

# Cosign
RUN wget https://github.com/sigstore/cosign/releases/download/v2.2.3/cosign-linux-amd64 \
    && mv cosign-linux-amd64 /usr/local/bin/cosign \
    && chmod +x /usr/local/bin/cosign

# Helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

# Maven settings for Nexus
RUN mkdir -p /home/jenkins/.m2
COPY settings.xml /home/jenkins/.m2/settings.xml
RUN chown -R jenkins:jenkins /home/jenkins/.m2

USER jenkins
