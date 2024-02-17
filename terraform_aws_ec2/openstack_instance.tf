#VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# Declare the data source
data "aws_availability_zones" "available" {}

# subnet
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Default subnet for ${data.aws_availability_zones.available.names[0]}"
  }
}

# create security group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_default_vpc.default.id

  dynamic "ingress" {
    for_each = [22, 80]
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

# create ssh key in AWS
resource "aws_key_pair" "openstack-server-key" {
  key_name   = "openstack-key"
  public_key = file("${path.module}/id_rsa.pub")
}


# Create ec2 instance with the ssh key
resource "aws_instance" "openstack_server" {
  ami                    = "ami-081375038454ad4d5"
  instance_type          = "t4g.xlarge"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  key_name               = aws_key_pair.openstack-server-key.key_name
  root_block_device {
    volume_size = 30
  }


  tags = {
    Name = "${var.ec2_instance_name}"
  }


}


resource "null_resource" "trigger_ansible" {

  #ssh into instance
  connection {
    type        = "ssh"
    user        = "centos"
    private_key = file("${path.module}/id_rsa")
    host        = aws_instance.openstack_server.public_ip
  }


  provisioner "local-exec" {

    command = "echo '[openstack-server]' > ../ansible_ws/inventory"
  }

  provisioner "local-exec" {
    command = "echo '${aws_instance.openstack_server.public_ip} ansible_user=centos ansible_ssh_private_key_file=../terraform_aws_ec2/${var.privateKey}' >> ../ansible_ws/inventory"
  }

  provisioner "local-exec" {

    working_dir = "../ansible_ws/"

    command = <<-EOT
      echo "[defaults]" > ansible.cfg
      echo "host_key_checking=False" >> ansible.cfg
      echo "inventory=./inventory" >> ansible.cfg
      echo "remote_user=centos" >> ansible.cfg
      echo "private_key_file =../terraform_aws_ec2/id_rsa" >> ansible.cfg
      echo "ask_pass=false" >> ansible.cfg
      echo "deprecation_warnings=False" >> ansible.cfg
      echo "" >> ansible.cfg
      echo "[privilege_escalation]" >> ansible.cfg
      echo "become= true" >> ansible.cfg
      echo "become_method = sudo" >> ansible.cfg
      echo "become_user = root" >> ansible.cfg
      echo "become_ask_pass = false" >> ansible.cfg
    EOT

  }


  provisioner "local-exec" {
    command = "echo '${aws_instance.openstack_server.public_ip}' > ../ansible_ws/openstack_server_pub_ip.txt"
  }


  provisioner "local-exec" {
    command = "echo '${var.ec2_instance_name}' > ../ansible_ws/openstack_server_name.txt"
  }





  provisioner "local-exec" {
    working_dir = "../ansible_ws/"
    command     = "ansible-playbook tf_ansible_openstack.yml"

  }



  depends_on = [aws_instance.openstack_server]

}


output "Openstack-Server-Name" {
  value = aws_instance.openstack_server.tags["Name"]

}


output "OpenStack-Server-IP" {
  value = aws_instance.openstack_server.public_ip

}

output "OpenStack-Cloud-Dashboard" {
  value = "http://${aws_instance.openstack_server.public_ip}/dashboard"

}


