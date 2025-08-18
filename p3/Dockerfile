FROM ubuntu:20.04

# Installer les dépendances
RUN apt-get update && \
    apt-get install -y curl ca-certificates docker.io && \
    rm -rf /var/lib/apt/lists/*

# Installer k3d
RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# # Vérifier l'installation
# RUN k3d --version

#installer kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

# Copie du fichier de configuration et manifeste
COPY ./script/setup.sh /usr/local/bin/setup.sh
COPY ./script/argocd-app.yaml /usr/local/bin/argocd-app.yaml
RUN chmod +x /usr/local/bin/setup.sh

CMD [ "bash", "-c", "/usr/local/bin/setup.sh && tail -f /dev/null" ]