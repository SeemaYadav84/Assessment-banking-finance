resource "aws_instance" "EC2-server" {
  ami = "ami-09040d770ffe2224f"
  instance_type = "t2.micro"
  key_name = "web1-key"
  vpc_security_group_ids= ["sg-040e4d07776a9f29f"]
  tags = {
    Name = "EC2-server"
  }
  
  provisioner "remote-exec" {
      connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = tls_private_key.web1-key.private_key_pem
    host     = self.public_ip
    }
    inline = [
      "ansible-playbook /var/lib/jenkins/workspace/Banking-Pipeline/tfscripts/Banking-playbook.yml"
    ]
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
resource "local_file" "web1-key" {
  content  = tls_private_key.web1-key.private_key_pem
  filename = "web1-key.pem"
}
