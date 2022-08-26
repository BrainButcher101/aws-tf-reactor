##############
# Launch Config
##############


resource "aws_launch_configuration" "launch" {
  instance_type = var.instance_type
  image_id      = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id

  key_name        = aws_key_pair.key_pair.id
  security_groups = [aws_security_group.security_group.id]
  user_data       = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }

}

##########
#Throw-away private key
##########

resource "tls_private_key" "public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
###########


resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.public_key.public_key_openssh
}

###########
#Security Groups
###########

resource "aws_security_group" "int_security_group" {
  name = "${var.name_prefix}_security_group"
}

resource "aws_security_group" "lb_security_group" {
  name = "${var.name_prefix}_lb_security_group"
}

resource "aws_security_group_rule" "int_inbound_http" {
  type              = "ingress"
  security_group_id = aws_security_group.int_security_group.id
  from_port         = var.server_port
  to_port           = var.server_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "int_inbound_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.int_security_group.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "int_outbound_everything" {
  type              = "egress"
  security_group_id = aws_security_group.int_security_group.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb_inbound_http" {
  type              = "ingress"
  security_group_id = aws_security_group.lb_security_group.id
  from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb_outbound_everything" {
  type              = "egress"
  security_group_id = aws_security_group.lb_security_group.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

########
#Autoscaling Groups
########

resource "aws_autoscaling_group" "auto_scaling_group" {
  name_prefix = "${var.name_prefix}-reactor-asg-"
  launch_configuration = var.launch_config_name
  vpc_zone_identifier  = var.public_subnets

  min_size = 1
  max_size = 2

  target_group_arns = [aws_lb_target_group.target_group.arn]

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}_auto_scaling_group"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_launch_configuration.launch]
}

#########
#Load Balancer
#########

resource "aws_lb" "load_balancer" {
  name               = "${var.name_prefix}-load-balancer"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.lb_security_group.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_listener_rule" "load_balancer_listerner_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group" "target_group" {

  name = "${var.name_prefix}-target-group"

  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


