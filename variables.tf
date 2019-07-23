variable "aws-region" {
  type = "string"
  default = "ap-south-1"
}
variable "vpc" {
    type = "map"
    default = {
        name = "Main-VPC"
        cidr = "10.100.0.0/16"
    }
}

variable "subnets" {
    type = "list"
    default = [
        {
            name = "Public-1a"
            cidr = "10.100.1.0/24"
            publicip = "true"
            availregion = "ap-south-1a"
        },
        {
            name = "private-1a"
            cidr = "10.100.50.0/24"
            publicip = "false"
            availregion = "ap-south-1a"
        }
    ]
  
}


