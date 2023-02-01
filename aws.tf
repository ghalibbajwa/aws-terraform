provider "aws" {
  
   region   = "sa-east-1"
   shared_credentials_file = "aws"
   profile = "default"
  
 }
data "aws_ami" "ubuntu" {

    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_security_group" "all" {
  name = "all-trafic"
  description = "Allow all"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "awskey" {
key_name   = "awskey"
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCTqVLKhPx+VghlURDrWpT2x4YuXpT0iIeYgLrC6+URNuDxjYbzz4yYmNLJdJay8kb18qaaCKsxjK72C0Dw9QxIzUOETyX/hvyBhkzIkz+eiek9a0pr0zWZYMcU5N2VmZnNVuVobQt5e6QM7ZZmuTcCxXjdn4kMfemCHfVTSBROYdudov7zQ/H2pBxTyBbxEbyHklB7kN7cbvDf6tcnqUV1KH6ZgQDKRVWpiQhf3Vu5KQJM9CyG0MgZbJHGpGyqVh+E+59TafQOlJaPAi0+K6yWlOKTSutv5LZDhkha73uDran/s3R5OXGDoClJKpL+AukXCkzoSx6eNEO8XRf3UGU/ awskey"
}


resource "aws_instance" "terra_ubuntu" {

   provisioner "file" {
    source      = "slogr"
    destination = "/home/ubuntu/slogr"

    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("awsk")
    host     = "${self.public_ip}" 
    }
  }

   provisioner "file" {
    source      = "app.py"
    destination = "/home/ubuntu/app.py"

    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("awsk")
    host     = "${self.public_ip}" 
    }
  }
   provisioner "file" {
    source      = "slogr.service"
    destination = "/home/ubuntu/slogr.service"

    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("awsk")
    host     = "${self.public_ip}" 
    }
  }
   provisioner "file" {
    source      = "flask.service"
    destination = "/home/ubuntu/flask.service"

    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("awsk")
    host     = "${self.public_ip}" 
    }
  }
 

  connection {
    type     = "ssh"
     user     = "ubuntu"
    private_key = file("awsk")
    host     = "${self.public_ip}"
  }
  provisioner "remote-exec" {
    inline = [
      "export ip=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)",
      "chmod +x slogr",
      "chmod +x slogr.service",
      "chmod +x flask.service",
      "chmod +x app.py",
      "sudo apt update -y",
      "sudo apt install python3-pip -y",
      "pip install flask",
      "sudo cp flask.service /etc/systemd/system/",
      "sudo cp slogr.service /etc/systemd/system/",
      "sudo systemctl start slogr.service",
      "sudo systemctl start flask.service",
      
    ]
  }


  
   ami = data.aws_ami.ubuntu.image_id
   instance_type = "t2.micro"
   vpc_security_group_ids = [aws_security_group.all.id]
   key_name= "awskey"
  
   tags = {
  
   name = "terr-ubuntu"
  
   }
  
 }
