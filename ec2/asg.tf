# module "master_asg" {
#   source = "terraform-aws-modules/autoscaling/aws"

#   # Autoscaling group
#   name            = "pub_master_asg"
#   use_name_prefix = false

#   min_size                  = 0
#   max_size                  = 1
#   desired_capacity          = 1
#   wait_for_capacity_timeout = 0
#   health_check_type         = "EC2"
#   vpc_zone_identifier       = module.vpc.public_subnets
#   service_linked_role_arn   = aws_iam_service_linked_role.autoscaling.arn

#   instance_refresh = {
#     strategy = "Rolling"
#     preferences = {
#       min_healthy_percentage = 0
#     }
#     triggers = ["tag"]
#   }

#   # Launch configuration
#   lc_name   = "master_lc"
#   use_lc    = true
#   create_lc = true

#   image_id          = data.aws_ami_ids.ubuntu.ids[0]
#   instance_type     = "t3.medium"
#   key_name          = "kubeadmKey"

#   iam_instance_profile_name    = aws_iam_instance_profile.ssm.id
#   security_groups             = [module.default_sg.security_group_id]
#   associate_public_ip_address = true

#   root_block_device = [
#     {
#       delete_on_termination = true
#       encrypted             = true
#       volume_size           = "50"
#       volume_type           = "gp2"
#     },
#   ]
# }

# # module "master_asg" {
# #   source = "terraform-aws-modules/autoscaling/aws"

# #   # Autoscaling group
# #   name            = "pub_master_asg"
# #   use_name_prefix = false

# #   min_size                  = 0
# #   max_size                  = 3
# #   desired_capacity          = 3
# #   wait_for_capacity_timeout = 0
# #   health_check_type         = "EC2"
# #   vpc_zone_identifier       = module.vpc.public_subnets
# #   service_linked_role_arn   = aws_iam_service_linked_role.autoscaling.arn

# #   instance_refresh = {
# #     strategy = "Rolling"
# #     preferences = {
# #       min_healthy_percentage = 0
# #     }
# #     triggers = ["tag"]
# #   }

# #   # Launch configuration
# #   lc_name   = "master_lc"
# #   use_lc    = true
# #   create_lc = true

# #   image_id          = data.aws_ami_ids.ubuntu.ids[0]
# #   instance_type     = "t3.small"
# #   key_name          = "kubeadmKey"

# #   iam_instance_profile_name    = aws_iam_instance_profile.ssm.id
# #   security_groups             = [module.default_sg.security_group_id]
# #   associate_public_ip_address = true

# #   root_block_device = [
# #     {
# #       delete_on_termination = true
# #       encrypted             = true
# #       volume_size           = "20"
# #       volume_type           = "gp2"
# #     },
# #   ]
# # }