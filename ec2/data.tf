data "aws_ami_ids" "ubuntu" {
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }
}

data "terraform_remote_state" "vpc" {
    backend = "local"
    
    config = {
        path = "${path.module}/../vpc/terraform.tfstate"
    }
}

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    path = "${path.module}/../iam/terraform.tfstate"
  }
}
