##  (Free) AI Server with Docker, Prometheus, Gatus, and EC2

This project sets up a **Llama cpp server** on an **EC2 instance**, using **Docker** to host the server along with **Prometheus** for monitoring and **Gatus** for health checks. It uses **Terraform** to provision the EC2 instance and state management with **S3** and **DynamoDB** for Terraform state locking. This project also provides a set of **GitHub Actions workflows** for automating infrastructure provisioning and management.

### Project Overview

- **EC2 Instance**: Hosts the Llama cpp server inside a Docker container. ( Here we use the t3.micro)
- **Docker**: Runs Llama cpp server, Prometheus, and Gatus containers.
- **Terraform**: Automates provisioning of EC2 instances, S3 buckets, DynamoDB (for state locking), and other resources.
- **Prometheus**: Collects and stores metrics for monitoring the Llama cpp server.
- **Gatus**: Monitors the health status of the Llama cpp server.
- **GitHub Actions**: Provides workflows to automate Terraform provisioning, Docker setup, and server deployment.


### Prerequisites

Before starting, make sure you have the following tools and credentials:

- **Terraform** >= 1.0
- **Docker** >= 20.10
- **AWS CLI** (optional for manual AWS configuration)
- **AWS Account**: For provisioning EC2 instances, S3, DynamoDB, and other resources.
- **GitHub Account**: For using GitHub Actions.

### AWS Credentials in GitHub Secrets

For the workflows to interact with AWS resources, **AWS credentials** and the **SSH private key** (for EC2 access) need to be stored as GitHub secrets. The following secrets are required:

1. **AWS_ACCESS_KEY_ID**
2. **AWS_SECRET_ACCESS_KEY**
3. **SSH_PRIVATE_KEY**: Used for SSH access to the EC2 instance.

To add secrets in GitHub:

1. Go to your repository on GitHub.
2. Navigate to **Settings** > **Secrets and variables** > **Actions**.
3. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `SSH_PRIVATE_KEY`

### AWS Permissions

Ensure that the AWS credentials you use have the necessary permissions to provision EC2 instances, S3 buckets, DynamoDB tables, and other resources required by Terraform.

## GitHub Actions Workflows

This project includes three GitHub Actions workflows for automating various tasks. These workflows are defined in `.github/workflows/` directory.

### 1. **Terraform Provisioning Workflow**

This workflow provisions the infrastructure using Terraform, including:

- EC2 instance
- S3 bucket for Terraform state storage
- DynamoDB table for state locking

To run this workflow, make sure the necessary GitHub secrets (AWS credentials and SSH key) are added, and then trigger the workflow manually or on push.

- **Workflow File**: `.github/workflows/terraform_1.yml`
  
The workflow steps are:
- Set up AWS credentials.
- Run `terraform init` and `terraform apply` to provision the resources.

### 2. **Docker Setup Workflow**

This workflow runs the Docker setup on the EC2 instance. It includes:

- Deploying the **Llama cpp server** in a Docker container.
- Deploying **Prometheus** for monitoring.
- Deploying **Gatus** for health checks.

- **Workflow File**: `.github/workflows/docker_playbook_workflow.yml`
For this workflow you will need to enter the IP address obtained by the first workflow terraform_1.yml
The workflow steps are:
- SSH into the EC2 instance using the SSH private key.
- Pull the Docker images.
- Start the Llama cpp server, Prometheus, and Gatus containers.

### 3. **Terraform Destroy Workflow**

This workflow destroys the infrastructure created by Terraform, cleaning up all AWS resources.

- **Workflow File**: `.github/workflows/destroy.yml`

The workflow steps are:
- Run `terraform destroy` to tear down the infrastructure.

### API Request Documentation

To interact with the **Llama cpp server** API, you can make a **POST** request to the `/completion` endpoint. This endpoint allows you to send a prompt and receive a generated response based on the provided input.

#### **Making a POST Request with `curl`**

You can use the following `curl` command to request data from the Llama cpp server. The request includes a **prompt**, **temperature** (used to control randomness), and **n_predict** (the number of tokens to predict).

##### **Example Request**

```bash
curl --request POST \
  --url http://16.16.182.0:8080/completion \
  --header "Content-Type: application/json" \
  --data '{"prompt": "What is EC2 instance?", "temperature": 0, "n_predict": 100}' | jq -r '.content'
```

##### **Request Parameters:**

- **`prompt`** (required): The text prompt you want the model to respond to. In this example, the prompt is `"What is EC2 instance?"`.
- **`temperature`** (optional): Controls the randomness of the output. Values range from 0 to 1, where 0 makes the output deterministic and 1 makes it more random. In the example above, the temperature is set to `0`.
- **`n_predict`** (optional): Specifies the number of tokens the model should predict in response to the prompt. The example above requests 100 tokens.

#### **API Response**

The server will return a JSON response that includes the generated text. Here's an example response format:

```json
{
  "content": "An EC2 instance is a virtual server in AWS that can run applications, process data, and provide scalable resources in the cloud..."
}
```
### **More Information About the API**

For additional details about the API, such as other available endpoints, authentication, and configuration, please check out the [Llama.cpp API documentation](https://github.com/ggml-org/llama.cpp/blob/master/examples/server/README.md).

---

# **Monitoring Setup: Gatus & Prometheus**

This project includes **Gatus** and **Prometheus** for monitoring and uptime checks of the **Llama cpp server** running inside a **Docker container** on an **AWS EC2 instance**.

## **Accessing Monitoring Services**

You can access the monitoring dashboards using the **public IP** of your EC2 instance.

- **Gatus (Health Checks & Uptime Monitoring)** → [`http://<EC2_PUBLIC_IP>:8000`](http://<EC2_PUBLIC_IP>:8000)  
- **Prometheus (Metrics & Monitoring)** → [`http://<EC2_PUBLIC_IP>:80`](http://<EC2_PUBLIC_IP>:80)  

Replace **`<EC2_PUBLIC_IP>`** with the actual **public IP address** of your EC2 instance.

---
## Summary of Setup 

| Step | Description |
|------|------------|
| **Clone Repo** | `git clone https://github.com/helloworld53/llama-cpp-server.git` |
| **Setup GitHub Secrets** | Add AWS credentials & SSH private key |
| **Run Workflows** | Terraform, Ansible, and Monitoring workflows in GitHub Actions |
| **Access API** | `http://<EC2_PUBLIC_IP>:8080/completion` |
| **Gatus Dashboard** | `http://<EC2_PUBLIC_IP>:8000` (Health Checks) |
| **Prometheus Dashboard** | `http://<EC2_PUBLIC_IP>:80` (Metrics) |

---
