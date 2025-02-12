provider "aws" {
  region = "us-east-1"
}

# Resource with all required tags
resource "aws_lb" "alb" {
  name               = "test-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0123456789abcdef0"]
  subnets            = ["subnet-0123456789abcdef0", "subnet-0abcdef0123456789"]

  tags = {
    applicationUid = "cloudplatform"
    assignment_group = "Cloud Engineering"
    environment = "dev"
    car_id = "1234"
  }
}

# Resource missing some required tags
resource "aws_lb" "alb_missing_tags" {
  name               = "test-alb-missing-tags"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0123456789abcdef0"]
  subnets            = ["subnet-0123456789abcdef0", "subnet-0abcdef0123456789"]

  tags = {
    applicationUid = "cloudplatform"
    environment = "dev"
  }
}

# Resource with no tags
resource "aws_lb_target_group" "alb_target_group_no_tags" {
  name     = "test-tg-no-tags"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0123456789abcdef0"
}

# Resource with tags corrected
resource "aws_s3_bucket" "bucket_with_tags" {
  bucket = "test-bucket-with-tags"

  tags = {
    applicationUid = "cloudplatform"
    assignment_group = "Cloud Engineering"
    environment = "dev"
    car_id = "5678"
  }
}

# Resource that does not support tags
resource "aws_iam_role_policy_attachment" "iam_no_tags" {
  role       = "test-iam-role"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
