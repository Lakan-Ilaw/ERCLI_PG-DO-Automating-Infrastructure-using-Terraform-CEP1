provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "Project_Server_Creation" {
  count         = 3
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.medium"
  key_name      = "Ricky_Project"
  vpc_security_group_ids = [aws_security_group.Project_Security_Group.id]
  tags = {
    Name = "Ricky_Project_Server_${count.index + 1}"
  }
}
resource "aws_security_group" "Project_Security_Group" {
  name_prefix = "Project_Security_Group"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all incoming traffic from any IPv4 address"
  }
  egress {
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outgoing apt update traffic (HTTP and HTTPS) to any IPv4 address"
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outgoing apt install traffic (SSH) to any IPv4 address"
  }
}
resource "null_resource" "Installation_via_Ansible" {
  count = length(aws_instance.Project_Server_Creation)

  provisioner "local-exec" {
      command = "sleep 50"
    }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("/home/elmerlakanilawy/Ricky_Project1.pem")
    host        = aws_instance.Project_Server_Creation[count.index].public_ip
  }

  provisioner "local-exec" {
    command = "sleep 10 && ansible-playbook -i '${aws_instance.Project_Server_Creation.*.public_ip[count.index]},' Project_Ansible_Installation.yml --private-key=/home/elmerlakanilawy/Ricky_Project1.pem"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}
