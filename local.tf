locals {
  azs = slice(data.aws_availability_zones.all.names,0,2)
}