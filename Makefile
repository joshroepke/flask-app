# Define variables for commands
DOCKER_CMD := docker
MINIKUBE_CMD := minikube
KUBECTL_CMD := kubectl
BROWSER_CMD := open

# Docker repository details
DOCKER_REPO := joshroepke/flask-app

# Versioning
DOCKER_TAG ?= $(shell cat VERSION 2>/dev/null || echo "latest")
VERSION_FILE := VERSION

# Kuberntes manifest files
K8S_DEPLOYMENT_FILE := k8s/flask-app-deployment.yaml
K8S_MANIFEST_DIR := k8s/

# Minikube service details 
FLASK_SERVICE := flask-app-service
PROMETHEUS_SERVICE := prometheus

# Install tools
install: check-docker check-minikube check-kubectl

# Check if Docker is installed
check-docker:
	@if command -v $(DOCKER_CMD) > /dev/null 2>&1; then \
		echo "Docker is already installed"; \
	else \
		echo "Docker not found. Go install Docker"; \
	fi

# Check if Minikube is installed
check-minikube:
	@if command -v $(MINIKUBE_CMD) > /dev/null 2>&1; then \
		echo "Minikube is already installed"; \
	else \
		echo "Minikube not found. Go install minikube!"; \
	fi

# Check if Kubectl is installed 
check-kubectl: 
	@if command -v $(KUBECTL_CMD) > /dev/null 2>&1; then \
		echo "Kubectl is already installed"; \
	else \
		echo "Kubectl is not found. Go install kubectl!"; \
	fi

# Increment the version in the VERSION file
increment-version:
	@echo "Incrementing version"
	@if [ -f $(VERSION_FILE) ]; then \
		awk -F. '{print $$1"."$$2"."$$3+1}' $(VERSION_FILE) > $(VERSION_FILE).tmp && mv $(VERSION_FILE).tmp $(VERSION_FILE); \
	else \
		echo "0.0.1" > $(VERSION_FILE); \
	fi
	@echo "New version: $(shell cat $(VERSION_FILE))"

# Build Docker container and push to repository
build-and-push: check-docker
	@if [ -z "$(TAG)" ]; then \
		$(MAKE) increment-version; \
		DOCKER_TAG=$(shell cat $(VERSION_FILE)); \
	else \
		DOCKER_TAG=$(TAG); \
	fi
	@echo "Building Docker image with tag: $(DOCKER_TAG)"
	$(DOCKER_CMD) build -t $(DOCKER_REPO):$(DOCKER_TAG) .
	@echo "Pushing Docker image to repository"
	$(DOCKER_CMD) push $(DOCKER_REPO):$(DOCKER_TAG)
	@echo "Docker image pushed successfully."

# Setup minikube 
minikube-start:
	@echo "Setting Minikube cluster with Docker driver"
	@$(MINIKUBE_CMD) start --driver=$(DOCKER_CMD)

# Destroy miniube cluster 
minikube-delete:
	@echo "Destroy Minikube cluster"
	@$(MINIKUBE_CMD) delete

# Deploy to Kubernetes with the correct image tag
deploy:
	@echo "Deploying to Kubernetes with image tag: $(DOCKER_TAG)"
	@sed "s|image: $(DOCKER_REPO):.*|image: $(DOCKER_REPO):$(DOCKER_TAG)|" $(K8S_DEPLOYMENT_FILE) | $(KUBECTL_CMD) apply -f -
	@echo "Deploying all k8s manifest files"
	@$(KUBECTL_CMD) apply -f $(K8S_MANIFEST_DIR)
	@echo "Deployment completed."