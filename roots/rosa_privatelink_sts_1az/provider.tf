terraform {
    required_version = ">= 0.12.0"
}

provider "aws" {
	#access_key = var.aws_access_key
	#secret_key = var.aws_secret_key
    #shared_credentials_file = "aws-credentials.ini"
	region = var.aws_region
	ignore_tags {
        key_prefixes = ["kubernetes.io/"]
    }
}
