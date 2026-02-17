//terraform {
 // required_providers {
//    aws = {
//      source  = "hashicorp/aws"
//      version = "~> 5.24.0" # latest v5 release
//    }
//  }

//  required_version = ">= 1.5.0"
//}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.18"
    }
  }
  required_version = ">= 1.5"
}