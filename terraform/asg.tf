module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "manisha-asg"

  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  # Launch template
  launch_template_name        = "manisha-asg-launch-template"
  launch_template_description = "Launch template for creating the node application"
  update_default_version      = true

  image_id          = "ami-0ac786bb439d4673b"
  instance_type     = "t3a.micro"
  key_name = "manisha_mern_key"
  user_data = filebase64("cw_agent.sh")
  security_groups = [resource.aws_security_group.Security-node-manisha.id]
  target_group_arns = module.alb.target_group_arns


  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = "codedeploy-role-manisha"
  iam_role_path               = "/ec2/"
  iam_role_description        = "IAM role for SSM, Code Deploy and S3 access"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonEC2 = "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    AmazonCodeDeploy = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess",
    AmazonS3Access = "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    AmazonEC2ForCodeDeploy = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
    AmazonEc2ForSSM = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
    AmazonSSMAccess = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"


  }



#Attach IAM role for SSM access to run wizard, Code deploy and other policies
#iam_instance_profile_name = "codedeploy_role_for_ec2"

}


##################################################################################################

resource "aws_security_group" "Security-node-manisha" {
  name        = "security-node-manisha"
  description = "Allow TLS inbound and outbund traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [module.vpc.vpc_cidr_block]
  }

 ingress {
    description      = "TLS from VPC"
    from_port        = 3000
    to_port          = 3000
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
    Name = "security-node-manisha"
    owner = "manisha"
  }
}

########################################################################################################################
