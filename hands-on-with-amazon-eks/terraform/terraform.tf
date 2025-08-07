terraform {
  required_providers {
    aws = { 
      source = "hashicorp/aws"
      version = "~>6.0"
    }
    
    randon = { 
      source = "hashcorp/random"
      version = "~>3.4.3"
    }

    tls = {
      source = "hashcorp/tls"
      version = "~>4.0.4"
    }

    cloudinit = {
      source = "hashcorp/cloudinit"
      version = "~>2.2.0"
    }

  }
}
