resource "aws_instance" "EC2-server" {
  ami = "ami-04b70fa74e45c3917"
  instance_type = "t2.medium"
  key_name = "web1-key"
  vpc_security_group_ids= ["sg-04abe48ace52cdbac"]
  
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
      "sudo apt update -y",
      "sudo apt install docker.io -y",
      "sudo systemctl start docker",
      "sudo wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64",
      "sudo chmod +x /home/ubuntu/minikube-linux-amd64",
      "sudo cp minikube-linux-amd64 /usr/local/bin/minikube",
      "curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl",
      "sudo chmod +x /home/ubuntu/kubectl",
      "sudo cp kubectl /usr/local/bin/kubectl",
      "sudo usermod -aG docker ubuntu"
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

output "ec2_ips" {
  value = aws_instance.EC2-server.public_ip
}

