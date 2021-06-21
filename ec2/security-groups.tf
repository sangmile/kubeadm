module "k8s_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "k8s-sg"
  description = "k8s security group"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = var.local_ip
    },
    {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      description = "kubectl"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  
  ingress_with_self = [
    {
      rule = "all-all"
    }
  ]
  
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
}
