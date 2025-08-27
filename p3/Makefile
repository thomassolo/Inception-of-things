.PHONY: help install setup clean test status logs deploy-app sync-app port-forward stop-port-forward clean-all

# Default target
help:
	@echo "=== Inception of Things (IoT) - Part 3 Makefile ==="
	@echo ""
	@echo "Available targets:"
	@echo "  help           - Show this help message"
	@echo ""
	@echo "🚀 Setup Commands:"
	@echo "  install        - Install Docker, K3d, kubectl, Argo CD CLI"
	@echo "  setup          - Create K3d cluster and install Argo CD"
	@echo "  deploy         - Deploy application via Argo CD"
	@echo "  setup-all      - Complete setup from scratch"
	@echo ""
	@echo "🧪 Test Commands:"
	@echo "  test           - Run all validation tests"
	@echo "  status         - Show cluster and application status"
	@echo "  logs           - Show Argo CD and application logs"
	@echo "  test-app       - Test application response"
	@echo ""
	@echo "🌐 Network Commands:"
	@echo "  port-forward   - Start port forwarding for Argo CD and app"
	@echo "  stop-pf        - Stop all port forwarding"
	@echo ""
	@echo "🧹 Cleanup Commands:"
	@echo "  clean          - Clean P3 cluster and resources"
	@echo "  clean-all      - Clean everything (all clusters)"
	@echo ""
	@echo "📝 Help Commands:"
	@echo "  version-help   - Instructions for v1→v2 testing"
	@echo ""
	@echo "📋 Quick Start:"
	@echo "  make install && make setup && make deploy"

# Install all dependencies
install:
	@echo "🔧 Installing dependencies..."
	sudo ./scripts/install_dep.sh
	@echo "✅ Dependencies installed. Please logout/login to apply docker group changes"

# Setup K3d cluster and Argo CD
setup:
	@echo "🚀 Setting up K3d cluster and Argo CD..."
	chmod +x ./scripts/setup.sh
	./scripts/setup.sh
	@echo "✅ P3 setup completed"

# Deploy application via Argo CD
deploy:
	@echo "📦 Deploying application via Argo CD..."
	kubectl apply -f ./scripts/argocd-app.yaml
	@echo "⏳ Waiting for application to sync..."
	@sleep 10
	kubectl wait --for=condition=Synced --timeout=300s application/playground-app -n argocd || true
	@echo "✅ Application deployed"

# Force application sync
sync-app:
	@echo "🔄 Forcing application sync..."
	kubectl patch application playground-app -n argocd --type merge -p '{"operation":{"sync":{}}}'
	@echo "✅ Sync triggered"

# Run all validation tests
test: status
	@echo "🧪 Running validation tests..."
	@echo ""
	@echo "📊 Testing cluster connectivity..."
	kubectl cluster-info --request-timeout=10s
	@echo ""
	@echo "📊 Testing namespaces..."
	kubectl get ns | grep -E "(argocd|dev)" || (echo "❌ Required namespaces missing" && exit 1)
	@echo ""
	@echo "📊 Testing Argo CD pods..."
	@RUNNING_PODS=$$(kubectl get pods -n argocd --no-headers | grep Running | wc -l); \
	if [ $$RUNNING_PODS -ge 7 ]; then \
		echo "✅ Argo CD pods running: $$RUNNING_PODS/7+"; \
	else \
		echo "❌ Not enough Argo CD pods running: $$RUNNING_PODS"; \
		exit 1; \
	fi
	@echo ""
	@echo "📊 Testing application deployment..."
	@POD_COUNT=$$(kubectl get pods -n dev --no-headers | wc -l); \
	if [ $$POD_COUNT -gt 0 ]; then \
		echo "✅ Application pods deployed: $$POD_COUNT"; \
	else \
		echo "❌ No application pods found in dev namespace"; \
		exit 1; \
	fi
	@echo ""
	@echo "🎉 All tests passed!"

# Show status of everything
status:
	@echo "📊 === CLUSTER STATUS ==="
	@echo "Clusters:"
	k3d cluster list
	@echo ""
	@echo "Nodes:"
	kubectl get nodes 2>/dev/null || echo "No cluster running"
	@echo ""
	@echo "📊 === NAMESPACES ==="
	kubectl get ns 2>/dev/null || echo "No cluster running"
	@echo ""
	@echo "📊 === ARGO CD STATUS ==="
	kubectl get pods -n argocd 2>/dev/null || echo "Argo CD not deployed"
	@echo ""
	@echo "📊 === APPLICATIONS ==="
	kubectl get applications -n argocd 2>/dev/null || echo "No applications found"
	@echo ""
	@echo "📊 === DEV NAMESPACE ==="
	kubectl get all -n dev 2>/dev/null || echo "Dev namespace empty"

# Show logs
logs:
	@echo "📋 === ARGO CD SERVER LOGS ==="
	kubectl logs -n argocd deployment/argocd-server --tail=20
	@echo ""
	@echo "📋 === APPLICATION LOGS ==="
	kubectl logs -n dev -l app=playground --tail=20 2>/dev/null || echo "No application pods found"

# Start port forwarding
port-forward:
	@echo "🌐 Starting port forwarding..."
	@echo "Argo CD UI will be available at: https://localhost:8080"
	@echo "Application will be available at: http://localhost:8888"
	@echo ""
	@echo "Argo CD credentials:"
	@echo "  Username: admin"
	@echo "  Password: $$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d)"
	@echo ""
	@echo "Starting port forwarding (press Ctrl+C to stop)..."
	@(kubectl port-forward svc/argocd-server -n argocd 8080:443 > /tmp/argocd-pf.log 2>&1 &)
	@(kubectl port-forward -n dev svc/playground-service 8888:80 > /tmp/app-pf.log 2>&1 &)
	@echo "Port forwarding started in background"
	@echo "To test the app: curl http://localhost:8888/"

# Stop port forwarding
stop-pf:
	@echo "🛑 Stopping port forwarding..."
	@pkill -f "kubectl port-forward" || true
	@echo "✅ Port forwarding stopped"

# Test application response
test-app:
	@echo "🧪 Testing application response..."
	@echo "Current version:"
	kubectl describe deployment playground-app -n dev | grep "Image:" || echo "No deployment found"
	@echo ""
	@echo "Testing API response (requires port forwarding to be active):"
	@curl -s http://localhost:8888/ 2>/dev/null || echo "❌ Cannot reach application. Start port forwarding with: make port-forward"

# Show version change instructions
version-help:
	@echo "📝 === VERSION CHANGE INSTRUCTIONS ==="
	@echo ""
	@echo "To test v1 → v2 transition:"
	@echo "1. Go to GitHub repo: https://github.com/PageBlanc/axdubois-iot-deployment"
	@echo "2. Edit the deployment file in manifests/"
	@echo "3. Change: wil42/playground:v1 → wil42/playground:v2"
	@echo "4. Commit and push changes"
	@echo "5. Wait for Argo CD to detect changes (auto-sync enabled)"
	@echo "6. Verify: make test-app"
	@echo ""
	@echo "Or manually sync: make sync-app"

# Clean P3 resources
clean:
	@echo "🧹 Cleaning P3 resources..."
	-@$(MAKE) stop-pf
	-k3d cluster delete iot-cluster 2>/dev/null || true
	@rm -f /tmp/argocd-pf.log /tmp/app-pf.log /tmp/argocd.log /tmp/app.log
	@echo "✅ P3 resources cleaned"

# Clean everything
clean-all:
	@echo "🧹 Cleaning all resources..."
	-@$(MAKE) stop-pf
	-k3d cluster delete --all 2>/dev/null || true
	-@docker system prune -f
	@rm -f /tmp/argocd*.log /tmp/app*.log
	@echo "✅ All resources cleaned"

# Complete setup from scratch
setup-all: clean setup deploy
	@echo "🎉 Complete setup finished!"
	@echo ""
	@make status
	@echo ""
	@echo "Next steps:"
	@echo "  make port-forward  - Start port forwarding"
	@echo "  make test-app      - Test the application"
	@echo "  make version-help  - Learn how to test v1→v2"

# Quick demo for evaluation
demo: setup-all port-forward
	@echo ""
	@echo "🎬 === DEMO READY ==="
	@echo ""
	@echo "✅ Cluster created with K3d"
	@echo "✅ Argo CD installed and running"
	@echo "✅ Application deployed in dev namespace"
	@echo "✅ Port forwarding active"
	@echo ""
	@echo "🌐 Access URLs:"
	@echo "  Argo CD: https://localhost:8080 (admin/password above)"
	@echo "  App API: http://localhost:8888/"
	@echo ""
	@echo "🧪 To test version change:"
	@echo "  make version-help"
