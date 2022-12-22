
#####################################################################################################
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["one", "two", "three"])

  name = "instance-manisha-mongo-${each.key}"

  ami                    = "ami-0ada6d94f396377f2"
  instance_type          = "t3a.micro"
  key_name               = "manisha_mern_key"
  monitoring             = true
  vpc_security_group_ids = [resource.aws_security_group.Security-mongo-manisha.id]
  subnet_id              = module.vpc.private_subnets[0]
  user_data              = filebase64("mongo_install.sh")

  tags = {
    Terraform   = "true"
    Environment = "dev"
    owner = "manisha"
  }
}

######################################################################################################
resource "aws_security_group" "Security-mongo-manisha" {
  name        = "security-mongo-manisha"
  description = "Allow TLS inbound and outbund traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [resource.aws_security_group.pritunl-vpn-sg.id]
    #cidr_blocks      = [module.vpc.vpc_cidr_block]
  }

 ingress {
    description      = "TLS from VPC"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "security-mongo-manisha"
    owner = "manisha"
  }
}

#########################################################################################

module "ec2_instance_bastion_server"   {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "manisha-bastion_server"

  ami                    = "ami-0ada6d94f396377f2"
  instance_type          = "t3a.micro"
  key_name               = "manisha_mern_key"
  monitoring             = true
  vpc_security_group_ids = [resource.aws_security_group.mansiha-sg-bastion-server.id]
  subnet_id              = module.vpc.public_subnets[0]
  tags = {
    Terraform   = "true"
    Environment = "dev"
    owner = "manisha"
  }
}

#########################################################################################

resource "aws_security_group" "mansiha-sg-bastion-server" {
  name        = "manisha-sg-bastion-server"
  description = "Allow TLS inbound and outbund traffic"
  vpc_id      = module.vpc.vpc_id

 ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "manisha-sg-bastion"
    owner = "manisha"
    terraform = true
    env = "dev"
 }
}

###################################################################################
