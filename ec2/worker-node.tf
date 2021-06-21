locals {
  workers = {
    worker1 = "worker1"
    worker2 = "worker2"
    worker3 = "worker3"
  }
}

module "k8s_worker_asg" {
  for_each = local.workers
  
  source  = "terraform-aws-modules/autoscaling/aws"
  
  name                = "k8s-${each.value}-asg"
  description            = "k8s"
  update_default_version = true
  
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = data.terraform_remote_state.vpc.outputs.public_subnets
  service_linked_role_arn   = data.terraform_remote_state.iam.outputs.autoscaling_role_arn

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 0
    }
    triggers = ["tag"]
  }


  # Launch Template
  lt_name   = "k8s-${each.value}-lt"
  use_lt    = true
  create_lt = true

  image_id          = data.aws_ami_ids.ubuntu.ids[0]
  instance_type     = "t3.small"
  key_name = "kubeadmKey"
  iam_instance_profile_arn = data.terraform_remote_state.iam.outputs.instance_profile_arn
  
  user_data_base64 = base64encode(data.template_file.user_data_worker[each.key].rendered)

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 100
        volume_type           = "gp2"
      }
    }
  ]

  network_interfaces = [
    {
      associate_public_ip_address = true
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [ module.k8s_sg.security_group_id ]
    }
  ]

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "k8s"
      propagate_at_launch = true
    },
  ]

}

data "template_file" "user_data_worker" {
    for_each = local.workers
    template = file("user-data.sh")
    
    vars = {
        hostname = "${each.value}"
        external_ip = var.external_ip
    }
}