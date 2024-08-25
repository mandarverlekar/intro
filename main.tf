provider "aws" {
  region = var.region
}

resource "aws_vpc" "poc-vpc" {
  cidr_block = var.vpc-cidr

  tags = {
    Name = "poc-vpc"
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.poc-vpc.id
  cidr_block              = var.public-subnet-1
  map_public_ip_on_launch = true
  availability_zone       = var.az-1

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.poc-vpc.id
  cidr_block              = var.public-subnet-2
  map_public_ip_on_launch = true
  availability_zone       = var.az-2
  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_internet_gateway" "poc-int-gw" {
  vpc_id = aws_vpc.poc-vpc.id

  tags = {
    Name = "poc-int-gw"
  }
}

resource "aws_route_table" "poc-rt" {
  vpc_id = aws_vpc.poc-vpc.id

  route {
    cidr_block = var.vpc-cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.poc-int-gw.id
  }
  tags = {
    Name = "poc-rt"
  }
}

resource "aws_route_table_association" "poc-rt-associate1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.poc-rt.id
}

resource "aws_route_table_association" "poc-rt-associate2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.poc-rt.id
}


resource "aws_autoscaling_group" "public-servers" {
  name                = "poc-asg"
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]


  launch_template {

    id      = aws_launch_template.poc-lauch-temp.id
    version = "$Latest"
  }

}

resource "aws_launch_template" "poc-lauch-temp" {

  image_id      = var.ami
  instance_type = var.instance-type
  key_name      = var.key_name

  #vpc_security_group_ids = [aws_security_group.poc-sg.id]

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.poc-sg.id]
  }

  user_data = filebase64("${path.module}/user-data.sh")

  tag_specifications {

    resource_type = "instance"
    tags = {
      Name = "first"
    }
  }

}

resource "aws_key_pair" "aws_poc2" {
  key_name   = "aws_poc2"
  public_key = file("${path.module}/public_key")
}

resource "aws_security_group" "poc-sg" {
  name        = "poc-sg-allow-all"
  description = "Allow All traffic"
  vpc_id      = aws_vpc.poc-vpc.id

  ingress {
    description = "Allow all inbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow All "
  }
}

resource "aws_lb" "poc-alb" {
  name               = "poc-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.poc-sg.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]

  tags = {
    Name = "poc-alb"
  }
}

resource "aws_lb_target_group" "poc-tg" {
  name     = "poc-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.poc-vpc.id
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "public-servers" {
  autoscaling_group_name = aws_autoscaling_group.public-servers.id
  lb_target_group_arn    = aws_lb_target_group.poc-tg.arn
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.poc-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.poc-tg.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.poc-alb.dns_name
}
