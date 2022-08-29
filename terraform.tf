terraform {
  /*
  cloud {
    workspaces {
      name = "learn-terraform-confluent-provider-alan"
    }
  }
  */
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.1.0"
    }
  }
  required_version = "~> 1.2.0"
}