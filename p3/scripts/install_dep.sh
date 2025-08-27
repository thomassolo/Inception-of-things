#!/bin/bash

echo "=== IoT Part 3 - Installing dependencies ==="
echo "Installing Docker, K3d, kubectl, and Argo CD CLI..."

# Exit on any error
set -e

# Update system packages
echo "Updating system packages..."
apt-get update -y

# Install prerequisites
echo "Installing prerequisites..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Install Docker
echo "Installing Docker..."
# Remove any existing Docker repository files to avoid conflicts
rm -f /etc/apt/sources.list.d/docker.list

# Add Docker's official GPG key for Debian
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository for Debian
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker packages
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Add current user to docker group
CURRENT_USER=$(logname 2>/dev/null || echo $SUDO_USER)
if [ -n "$CURRENT_USER" ] && [ "$CURRENT_USER" != "root" ]; then
    echo "Adding $CURRENT_USER user to docker group..."
    usermod -aG docker $CURRENT_USER
else
    echo "Warning: Could not determine non-root user to add to docker group"
fi

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Verify Docker installation
echo "Verifying Docker installation..."
docker --version

# Install K3d
echo "Installing K3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Verify K3d installation
echo "Verifying K3d installation..."
k3d version

# Install kubectl
echo "Installing kubectl..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl

# Verify kubectl installation
echo "Verifying kubectl installation..."
kubectl version --client

# Install Argo CD CLI
echo "Installing Argo CD CLI..."
ARGOCD_VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
curl -sSL -o argocd-linux-amd64 "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"
chmod +x argocd-linux-amd64
mv argocd-linux-amd64 /usr/local/bin/argocd

# Verify Argo CD CLI installation
echo "Verifying Argo CD CLI installation..."
argocd version --client

# Set up environment for current user
CURRENT_USER=$(logname 2>/dev/null || echo $SUDO_USER)
if [ -n "$CURRENT_USER" ] && [ "$CURRENT_USER" != "root" ]; then
    echo "Setting up environment for $CURRENT_USER user..."
    USER_HOME=$(eval echo ~$CURRENT_USER)
    
    # Create .bashrc additions
    cat >> $USER_HOME/.bashrc << 'EOF'

# K8s aliases and environment
export KUBECONFIG=$HOME/.kube/config
alias k=kubectl
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgi='kubectl get ingress'
alias kga='kubectl get all'
EOF

    # Create .kube directory for current user
    mkdir -p $USER_HOME/.kube
    chown -R $CURRENT_USER:$CURRENT_USER $USER_HOME/.kube
else
    echo "Warning: Could not determine non-root user for environment setup"
fi

# Install additional useful tools
echo "Installing additional tools..."
apt-get install -y \
    htop \
    tree \
    jq \
    vim \
    git

echo ""
echo "=== INSTALLATION COMPLETED ==="
echo ""
echo "Installed versions:"
echo "  Docker: $(docker --version)"
echo "  K3d: $(k3d version | head -1)"
echo "  kubectl: $(kubectl version --client --short)"
echo "  Argo CD CLI: $(argocd version --client --short)"
echo ""
echo "IMPORTANT: Please logout and login again to apply docker group changes"
echo "Then run: ./scripts/setup.sh to create the K3d cluster"
echo ""
echo "Manual verification commands:"
echo "  docker ps"
echo "  k3d cluster list"
echo "  kubectl cluster-info"