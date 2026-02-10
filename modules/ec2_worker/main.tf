resource "aws_instance" "ec2_worker" {
  count = var.instance_quantity

  instance_type                        = var.instance_type
  ami                                  = coalesce(var.launch_ami_id, data.aws_ami.ec2_worker_launch_default.id)
  monitoring                           = false
  instance_initiated_shutdown_behavior = "stop"

  vpc_security_group_ids = [aws_security_group.ec2_worker.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_worker.name
  key_name               = aws_key_pair.ec2_worker.key_name

  // Do not set subnet_id, it will be auto-selected from a default subnet

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
    tags = {
      Name = "${var.project_slug}-${count.index}"
    }
  }

  tags = {
    Name = "${var.project_slug}-${count.index}"
  }

  lifecycle {
    ignore_changes = [
      # Allow an updated AMI be used for new provisions without always recreating the machine
      ami,
    ]
  }
}

data "aws_ami" "ec2_worker_launch_default" {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "ec2_worker" {
  key_name   = var.project_slug
  public_key = var.ssh_public_key
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "ec2_worker" {
  name   = var.project_slug
  vpc_id = aws_default_vpc.default.id

  egress {
    description = "Any TCP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "DNS queries"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ec2_worker" {
  count = var.instance_quantity

  instance = aws_instance.ec2_worker[count.index].id

  tags = {
    Name = "${var.project_slug}-${count.index}"
  }
}
