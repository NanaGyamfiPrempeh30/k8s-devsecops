# Kubernetes DevSecOps Portfolio Project

A production-grade Kubernetes infrastructure demonstrating modern DevSecOps practices, GitOps workflows, and comprehensive observability. Built to showcase real-world cloud-native architecture skills.

![Kubernetes](https://img.shields.io/badge/kubernetes-v1.29-326ce5?logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-v1.5+-7B42BC?logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/ansible-2.15+-EE0000?logo=ansible&logoColor=white)
![ArgoCD](https://img.shields.io/badge/argocd-v2.9+-EF7B4D?logo=argo&logoColor=white)
![Vault](https://img.shields.io/badge/vault-v1.15+-FFEC6E?logo=vault&logoColor=black)

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS VPC (10.0.0.0/16)                          │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Private Subnet (10.0.1.0/24)                  │   │
│  │                                                                       │   │
│  │   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐             │   │
│  │   │  k8s-master │    │ k8s-worker1 │    │ k8s-worker2 │             │   │
│  │   │  (t3.medium)│    │ (t3.medium) │    │ (t3.medium) │             │   │
│  │   │             │    │             │    │             │             │   │
│  │   │ • API Server│    │ • Workloads │    │ • Workloads │             │   │
│  │   │ • etcd      │    │ • ArgoCD    │    │ • Vault     │             │   │
│  │   │ • Scheduler │    │ • Traefik   │    │ • Monitoring│             │   │
│  │   └──────┬──────┘    └──────┬──────┘    └──────┬──────┘             │   │
│  │          │                  │                  │                     │   │
│  │          └──────────────────┼──────────────────┘                     │   │
│  │                             │                                        │   │
│  │                    ┌────────┴────────┐                               │   │
│  │                    │    MetalLB      │                               │   │
│  │                    │  (10.0.1.200)   │                               │   │
│  │                    └────────┬────────┘                               │   │
│  │                             │                                        │   │
│  └─────────────────────────────┼────────────────────────────────────────┘   │
│                                │                                            │
└────────────────────────────────┼────────────────────────────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │   Traefik Ingress       │
                    │   Controller            │
                    └────────────┬────────────┘
                                 │
        ┌────────────────────────┼────────────────────────────┐
        │                        │                            │
   ┌────┴────┐            ┌──────┴──────┐            ┌───────┴───────┐
   │ ArgoCD  │            │   TaskApp   │            │  Monitoring   │
   │ GitOps  │            │  Frontend   │            │   Grafana     │
   │         │            │  Backend    │            │  Prometheus   │
   └─────────┘            └─────────────┘            └───────────────┘
```

## Technology Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| **Infrastructure as Code** | Terraform | AWS resource provisioning |
| **Configuration Management** | Ansible | Node configuration & K8s bootstrap |
| **Container Orchestration** | Kubernetes (kubeadm) | Workload management |
| **CNI** | Calico | Pod networking & network policies |
| **Load Balancer** | MetalLB | Bare-metal load balancer |
| **Ingress** | Traefik | HTTP routing & TLS termination |
| **Certificate Management** | cert-manager | Automated TLS certificates |
| **Secrets Management** | HashiCorp Vault | Centralized secrets storage |
| **Secrets Sync** | External Secrets Operator | Vault → K8s secret synchronization |
| **GitOps** | ArgoCD | Declarative continuous delivery |
| **Monitoring** | Prometheus & Grafana | Metrics collection & visualization |

## Features Demonstrated

### Infrastructure as Code
- **Terraform** provisions all AWS resources including VPC, subnets, security groups, and EC2 instances
- Modular structure with separate configurations for networking and compute
- State management with proper backend configuration

### Configuration Management
- **Ansible** playbooks for automated cluster bootstrapping
- Role-based organization for master and worker node configuration
- Idempotent configurations for reproducible deployments

### GitOps Workflow
- **ArgoCD** watches the Git repository for changes
- Automatic synchronization of Kubernetes manifests
- Self-healing capabilities with drift detection

### Secrets Management
- **HashiCorp Vault** stores sensitive data securely
- **External Secrets Operator** synchronizes secrets to Kubernetes
- Automatic secret rotation support
- No secrets stored in Git

### Observability
- **Prometheus** collects metrics from all components
- **Grafana** dashboards for visualization
- **Traefik** metrics integration for ingress monitoring
- Node-level and application-level monitoring

## Project Structure

```
k8s-devsecops/
├── terraform/
│   ├── ec2/                    # EC2 instance definitions
│   ├── vpc/                    # VPC and networking
│   └── variables.tf            # Input variables
├── ansible/
│   ├── inventory/              # Host definitions
│   ├── playbooks/              # Deployment playbooks
│   └── roles/                  # Reusable roles
├── kubernetes/
│   ├── apps/                   # Application manifests
│   │   ├── namespace.yaml
│   │   ├── frontend.yaml
│   │   ├── backend.yaml
│   │   └── ingress.yaml
│   ├── core/                   # Core infrastructure
│   └── monitoring/             # Prometheus & Grafana
├── argocd/
│   └── applications/           # ArgoCD Application definitions
├── application/
│   ├── frontend/               # React frontend source
│   ├── backend/                # Python FastAPI backend
│   └── database/               # Database configurations
└── docs/                       # Additional documentation
```

## Quick Start

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.5
- Ansible >= 2.15
- kubectl
- Docker (for building application images)

### 1. Infrastructure Provisioning

```bash
# Initialize and apply Terraform
cd terraform/ec2
terraform init
terraform plan
terraform apply
```

### 2. Cluster Configuration

```bash
# Run Ansible playbooks
cd ansible
ansible-playbook -i inventory/hosts playbooks/site.yml
```

### 3. Deploy Core Services

```bash
# Install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

# Install Traefik
helm install traefik traefik/traefik -n traefik --create-namespace

# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Install Vault
helm install vault hashicorp/vault -n vault --create-namespace --set "server.dev.enabled=true"

# Install External Secrets Operator
helm install external-secrets external-secrets/external-secrets -n external-secrets-system --create-namespace

# Install Prometheus & Grafana
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 4. Configure Vault Secrets

```bash
# Create secrets in Vault
kubectl exec -n vault vault-0 -- vault kv put secret/taskapp/config \
  DB_PASSWORD="your-secure-password" \
  API_KEY="your-api-key" \
  JWT_SECRET="your-jwt-secret"
```

### 5. Deploy Application via ArgoCD

Access ArgoCD UI and create a new application pointing to this repository's `kubernetes/apps` directory, or apply the ArgoCD Application manifest:

```bash
kubectl apply -f argocd/applications/taskapp.yaml
```

## Accessing Services

All services are exposed via Traefik ingress on the MetalLB IP (10.0.1.200):

| Service | URL |
|---------|-----|
| Task Application | http://taskapp.10.0.1.200.nip.io |
| ArgoCD | http://argocd.10.0.1.200.nip.io |
| Grafana | http://grafana.10.0.1.200.nip.io |
| Vault UI | http://vault.10.0.1.200.nip.io |
| Traefik Dashboard | http://traefik.10.0.1.200.nip.io/dashboard/ |

### SSH Tunnel Access (for private clusters)

```bash
# Create SSH tunnel
ssh -i k8s-key.pem ubuntu@<master-public-ip> -L 80:10.0.1.200:80 -N

# Add to /etc/hosts (or Windows hosts file)
127.0.0.1 taskapp.10.0.1.200.nip.io
127.0.0.1 argocd.10.0.1.200.nip.io
127.0.0.1 grafana.10.0.1.200.nip.io
127.0.0.1 vault.10.0.1.200.nip.io
127.0.0.1 traefik.10.0.1.200.nip.io
```

## Secrets Flow

```
┌─────────────┐     ┌─────────────────────┐     ┌─────────────────┐
│   Vault     │────▶│ External Secrets    │────▶│  K8s Secret     │
│             │     │ Operator            │     │                 │
│ secret/     │     │                     │     │ taskapp-secrets │
│ taskapp/    │     │ ClusterSecretStore  │     │                 │
│ config      │     │ ExternalSecret      │     │ DB_PASSWORD     │
│             │     │                     │     │ API_KEY         │
│ DB_PASSWORD │     │ Syncs every 1h      │     │ JWT_SECRET      │
│ API_KEY     │     │                     │     │                 │
│ JWT_SECRET  │     │                     │     │                 │
└─────────────┘     └─────────────────────┘     └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │  Backend Pod    │
                                               │                 │
                                               │ envFrom:        │
                                               │   secretRef:    │
                                               │     taskapp-    │
                                               │     secrets     │
                                               └─────────────────┘
```

## GitOps Workflow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Developer  │────▶│   GitHub    │────▶│   ArgoCD    │────▶│ Kubernetes  │
│             │     │             │     │             │     │   Cluster   │
│ git push    │     │ Repository  │     │ Detects     │     │             │
│             │     │             │     │ changes     │     │ Deploys     │
│             │     │ kubernetes/ │     │             │     │ manifests   │
│             │     │ apps/       │     │ Auto-sync   │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

## Monitoring & Observability

### Grafana Dashboards

- **Traefik Dashboard**: Request rates, response times, HTTP status codes
- **Kubernetes Cluster**: Node resources, pod status, namespace metrics
- **Node Exporter**: System-level metrics (CPU, memory, disk, network)

### Key Metrics Collected

- HTTP request rate and latency (via Traefik)
- Pod resource utilization
- Node health and capacity
- Application-specific metrics

## Security Features

- **Network Segmentation**: Private subnet for cluster nodes
- **Bastion Access**: SSH tunnel through master node
- **Secrets Management**: No secrets in Git, all managed via Vault
- **RBAC**: Kubernetes role-based access control
- **Network Policies**: Calico CNI for pod-level network security

## Lessons Learned

[Medium article "I Built a Production-Grade Kubernetes Platform in 48 Hours. Here’s Everything That Went Wrong (And How I Fixed It)"](https://medium.com/@yawgyamfiprempeh27/i-built-a-production-grade-kubernetes-platform-in-48-hours-db5629fba0e3)

1. **Memory Management**: Production Kubernetes clusters need adequate resources; t3.medium instances minimum for running full observability stack
2. **Ingress Configuration**: Host-based routing with nip.io requires careful port management when using SSH tunnels
3. **Operator Dependencies**: Prometheus Operator must be running for ServiceMonitors to be processed
4. **GitOps Flow**: Image tag updates must be committed to Git for ArgoCD to detect changes

## Future Enhancements

- [ ] Implement Istio service mesh
- [ ] Add automated backup with Velero
- [ ] Configure horizontal pod autoscaling
- [ ] Implement network policies with Calico
- [ ] Add CI pipeline with GitHub Actions
- [ ] Enable HTTPS with Let's Encrypt (requires public domain)

## Author

**[Y. Nana Gyamfi Prempeh](https://www.linkedin.com/in/yashwanth-kumar-jaishankar-56258a50/)**

DevSecOps Engineer | Kubernetes | Cloud Infrastructure | IaC

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Built as a portfolio project demonstrating end-to-end DevSecOps capabilities*
