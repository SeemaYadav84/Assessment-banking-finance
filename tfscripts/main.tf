resource "aws_instance" "EC2-server" {
  ami = "ami-09040d770ffe2224f"
  instance_type = "t2.micro"
  key_name = "TF_key"
  vpc_security_group_ids= ["sg-040e4d07776a9f29f"]
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "TF_key"
    host     = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [ "echo 'wait to start instance' "]
  }
  tags = {
    Name = "EC2-server"
  }
  provisioner "local-exec" {
        command = " echo ${aws_instance.EC2-server.public_ip} > inventory "
  }
   provisioner "local-exec" {
  command = "ansible-playbook /var/lib/jenkins/workspace/Banking-Pipeline/tfscripts/Banking-playbook.yml "
  } 
}

# Public key 
resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Private key 
resource "local_file" "TF-key" { 
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
}
