terraform {
  # State lives in S3 so a local run and the GitHub Actions pipeline share it.
  # The bucket has to already exist (scripts/bootstrap-state.sh makes it). S3
  # names are global, so change this if it's taken.
  backend "s3" {
    bucket       = "cs312-mc-tfstate-coffmacl"
    key          = "minecraft/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
