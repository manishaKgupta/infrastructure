module "pritunl" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  name = "Pritunl-Host-manisha"
  ami                    = "ami-0ada6d94f396377f2"
  instance_type          = "t3a.micro"
  key_name               = "manisha_mern_key"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.pritunl-vpn-sg.id]
  subnet_id              = element(module.vpc.public_subnets, 0)
  user_data = filebase64("./pritunl_vpn_dependency.sh")
  tags = {
    Terraform   = "true"
    Environment = "production"
    owner = "manisha"
  }
}


##################################################security group for pritunl

resource "aws_security_group" "pritunl-vpn-sg" {
  name = "Pritunl-SG-manisha"
  vpc_id = module.vpc.vpc_id
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "manisha-Pritunl-SG"
    Owner = "manisha"
  }
}