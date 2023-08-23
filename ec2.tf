data "aws_ssm_parameter" "amzn2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.system}-${var.env}-ec2-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.eic_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.system}-${var.env}-ec2-sg"
  }
  depends_on             = [
    aws_security_group.eic_sg
  ]
}

resource "aws_instance" "bastion_ec2" {
  ami           = data.aws_ssm_parameter.amzn2023_ami.value
  instance_type = "t2.micro"
  vpc_security_group_ids = [
    "${aws_security_group.ec2_sg.id}"
  ]
  subnet_id     = element(module.vpc.private_subnets, 0)
  tags = {
    Name = "${var.system}-${var.env}-ec2-bastion"
  }
}

resource "aws_security_group" "eic_sg" {
    name        = "${var.system}-${var.env}-eic-sg"
    description = "EIC Security Group"
    vpc_id            = module.vpc.vpc_id
}

resource "aws_security_group_rule" "eic_sg_rule" {
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = aws_security_group.ec2_sg.id
  security_group_id = aws_security_group.eic_sg.id
  depends_on             = [
    aws_security_group.ec2_sg
  ]
}

resource "aws_ec2_instance_connect_endpoint" "eic" {
    subnet_id = element(module.vpc.private_subnets, 0)
    security_group_ids = [aws_security_group.eic_sg.id]
    preserve_client_ip = true
    tags = {
        Name = "${var.system}-${var.env}-eice"
    }
}