
#####################################################################################################
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  
  count = 3
  name = "instance-manisha-mongo-${count.index}"
  ami                    = "ami-0ada6d94f396377f2"
  instance_type          = "t3a.micro"
  key_name               = "manisha_mern_key"
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
    #cidr_blocks      = [module.vpc.vpc_cidr_block]
    security_groups      = [resource.aws_security_group.pritunl-vpn-sg.id]
  }

 ingress {
    description      = "TLS from VPC"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
    security_groups      = [resource.aws_security_group.Security-node-manisha.id]
    #cidr_blocks     = [module.vpc.vpc_cidr_block]
    self             = true
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

##########################################################################################