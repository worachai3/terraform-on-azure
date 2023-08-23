terraform {
  backend "s3" {
    bucket         = "dev-applications-backend-state-worachai"
    key            = "dev/azure/backend-state"
    region         = "us-east-1"
    dynamodb_table = "dev-applications-locks"
    encrypt        = true
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "aws" {
  region = "us-east-1"  
}