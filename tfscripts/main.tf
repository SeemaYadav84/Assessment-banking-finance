resource "aws_instance" "EC2-server"{
  ami = "ami-09040d770ffe2224f"
  instance_type = "t2.micro"
  key_name = "Ansible_host_key"
  vpc_security_group_ids= ["sg-084e9b1aea742d17c"]
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("./Ansible_host_key.pem")
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
  command = "ansible-playbook /var/lib/jenkins/workspace/Banking-Pipeline/scripts/Banking-playbook.yml "
  } 
}
