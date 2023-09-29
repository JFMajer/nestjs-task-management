data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-*-x86_64"]
  }
}

locals {
  tags = {
    "environment"        = "#{ENV}#"
    "app_name"           = "${var.app_name}}"
    "lt_latest_version"  = module.asg.launch_template_latest_version
    "lt_default_version" = module.asg.launch_template_default_version
  }
}
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.10.0"

  name = "${var.app_name}-bastion-asg-#{ENV}#"

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  vpc_zone_identifier         = module.vpc.private_subnets
  health_check_type           = "EC2"
  image_id                    = data.aws_ami.amazon_linux.id
  user_data                   = filebase64("${path.module}/bastion.sh")
  create_iam_instance_profile = false
  iam_instance_profile_arn    = aws_iam_instance_profile.jump_host.arn
  security_groups             = [aws_security_group.jump_host_sg.id]
  instance_type               = "t3.small"
  instance_name               = "${var.app_name}-bastion"

  instance_market_options = {
    market_type = "spot"
  }

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

}

resource "aws_iam_instance_profile" "jump_host" {
  name = "${var.app_name}-jumphost-profile"
  role = aws_iam_role.jump_host.name
}

resource "aws_iam_role" "jump_host" {
  name               = "${var.app_name}-jumphost-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

// create policy for jump host to allow all operations on EKS
resource "aws_iam_policy" "jump_host" {
  name   = "${var.app_name}-jumphost-ekspolicy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jump_host" {
  role       = aws_iam_role.jump_host.name
  policy_arn = aws_iam_policy.jump_host.arn
}

resource "aws_iam_role_policy_attachment" "jump_host_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.jump_host.name
}

resource "aws_security_group" "jump_host_sg" {
  name        = "${var.app_name}-jumphost-sg"
  description = "Security group for jump host"

  vpc_id = module.vpc.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}