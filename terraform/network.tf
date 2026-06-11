# Use the account's default VPC and one of its public subnets. Learner Lab is
# flaky about creating new VPCs, and the default one already has public subnets.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_subnet" "selected" {
  id = tolist(data.aws_subnets.default.ids)[0]
}
