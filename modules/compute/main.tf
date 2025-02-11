# Bastion Host
resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  subnet_id            = var.public_subnets[0]
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.bastion.name

  vpc_security_group_ids = [var.bastion_sg_id]

  root_block_device {
    encrypted = true
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
              systemctl restart sshd
              EOF

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}bastion"
  })
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  tags = merge(var.tags, {
    Name = "${local.name_prefix}bastion-eip"
  })
}

# Load Balancer
resource "aws_lb" "web" {
  name               = "${local.name_prefix}web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets

  tags = merge(var.tags, {
    Name = "${local.name_prefix}alb"
  })
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

resource "aws_lb_target_group" "web" {
  name     = "${local.name_prefix}web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/health"
    port = 80
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}web-tg"
  })
}

# Web Servers
resource "aws_launch_template" "web" {
  name_prefix   = "${local.name_prefix}web-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.webserver_sg_id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF
  )

  tags = merge(var.tags, {
    Name = "${local.name_prefix}web-lt"
  })
}

resource "aws_autoscaling_group" "web" {
  name                = "${local.name_prefix}web-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1
  force_delete        = true
  target_group_arns   = [aws_lb_target_group.web.arn]
  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}web-asg"
    propagate_at_launch = true
  }
}

# IAM role for SSM access
resource "aws_iam_role" "bastion" {
  name = "${local.name_prefix}bastion-role"
  tags = merge(var.tags, {
    Name = "${local.name_prefix}bastion-role"
  })

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${local.name_prefix}bastion-profile"
  role = aws_iam_role.bastion.name
  tags = merge(var.tags, {
    Name = "${local.name_prefix}bastion-profile"
  })
}
