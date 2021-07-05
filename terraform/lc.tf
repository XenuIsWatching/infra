locals {
  image_id          = "ami-0e565ccb9dda657e4"
  staging_image_id  = "ami-0e565ccb9dda657e4"
  beta_image_id     = "ami-0e565ccb9dda657e4"
  conan_image_id    = "ami-0b41dc7a318b530bd"
  staging_user_data = base64encode("staging")
  beta_user_data    = base64encode("beta")
  // Current c5 on-demand price is 0.085. Yearly pre-pay is 0.05 (so this is same as prepaying a year)
  // Historically we pay ~ 0.035
  spot_price        = "0.05"
}

resource "aws_launch_configuration" "CompilerExplorer-beta-large" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix                 = "compiler-explorer-beta-large"
  image_id                    = local.beta_image_id
  instance_type               = "c5.large"
  iam_instance_profile        = aws_iam_instance_profile.CompilerExplorerRole.name
  key_name                    = "mattgodbolt"
  security_groups             = [aws_security_group.CompilerExplorer.id]
  associate_public_ip_address = true
  user_data                   = local.beta_user_data
  enable_monitoring           = false
  ebs_optimized               = true
  spot_price                  = local.spot_price

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }
}

resource "aws_launch_configuration" "CompilerExplorer-staging" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix                 = "compiler-explorer-staging"
  image_id                    = local.staging_image_id
  instance_type               = "c5.large"
  iam_instance_profile        = aws_iam_instance_profile.CompilerExplorerRole.name
  key_name                    = "mattgodbolt"
  security_groups             = [aws_security_group.CompilerExplorer.id]
  associate_public_ip_address = true
  user_data                   = local.staging_user_data
  enable_monitoring           = false
  ebs_optimized               = true
  spot_price                  = local.spot_price

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
  }
}

resource "aws_launch_template" "CompilerExplorer-prod" {
  name                   = "ce-prod"
  description            = "Production launch template"
  ebs_optimized          = true
  iam_instance_profile {
    arn = aws_iam_instance_profile.CompilerExplorerRole.arn
  }
  image_id               = local.image_id
  key_name               = "mattgodbolt"
  vpc_security_group_ids = [aws_security_group.CompilerExplorer.id]
  instance_type          = "c5.large"

  tag_specifications {
    resource_type = "volume"

    tags = {
      Site = "CompilerExplorer"
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Site = "CompilerExplorer"
    }
  }
}
