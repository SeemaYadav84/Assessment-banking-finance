resource "aws_instance" "EC2-server" {
  ami = "ami-09040d770ffe2224f"
  instance_type = "t2.medium"
  key_name = "web1-key"
  vpc_security_group_ids= ["sg-040e4d07776a9f29f"]
  
  tags = {
    Name = "EC2-server"
  }

 provisioner "file" {
    source      = "/var/lib/jenkins/workspace/Banking-Pipeline/tfscripts/Banking_app_deployment.yaml"
    destination = "/home/ubuntu/Banking_app_deployment.yaml"
}

 provisioner "file" {
    source      = "/var/lib/jenkins/workspace/Banking-Pipeline/tfscripts/service.yaml"
    destination = "/home/ubuntu/service.yaml"
 }

connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = tls_private_key.web1-key.private_key_pem
    host     = self.public_ip
}

 provisioner "remote-exec" {
    inline = [
"sudo apt update",
"curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64",
"sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64",
"sudo apt install docker.io -y",
"curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
"curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256",
"sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl",
"sudo usermod -aG docker ubuntu",
"newgrp docker",
"sudo systemctl start docker",
"minikube start",
"kubectl create -f springboot-deployment.yaml",
"Kubectl create -f spring-service.yaml"
    ]

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = tls_private_key.web1-key.private_key_pem
    host     = self.public_ip
    }
  }

  provisioner "local-exec" {
        command = " echo ${aws_instance.EC2-server.public_ip} > inventory "
  }
}

resource "tls_private_key" "web1-key" {
  algorithm   = "RSA"
}
#Public key 
resource "aws_key_pair" "app-key" {
  key_name   = "web1-key"
  public_key = tls_private_key.web1-key.public_key_openssh
}
#Private key 
resource "local_sensitive_file" "web1-key" {
  content  = tls_private_key.web1-key.private_key_pem
  file_permission = "600"
  directory_permission = "700"
  filename = "web1-key.pem"
}
