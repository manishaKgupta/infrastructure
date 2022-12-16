module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "my-alb-manisha"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [resource.aws_security_group.Security-alb-manisha.id]

  target_groups = [
    {
      name_prefix      = "maniTG"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:acm:us-east-2:421320058418:certificate/87e6149d-d52c-48d6-9202-5560c35daeef"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
 


  tags = {
    Environment = "Test"
    owner = "manisha"
  }
}


############################################################################################

resource "aws_security_group" "Security-alb-manisha" {
  name        = "security-alb-manisha"
  description = "Allow for alb TLS inbound and outbund traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }

 ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
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
    Name = "security-alb-manisha"
    owner = "manisha"
  }
}

###########################################################################################