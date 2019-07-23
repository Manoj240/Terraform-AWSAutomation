####################################
#outputs
#####################################
output "vpcmk_id" {
  value = "${aws_vpc.main.id}"
}
output "aws_publicsubetcidr" {
  value = "${aws_subnet.subnets.*.cidr_block}"
}
output "aws_privatesubnetcidr" {
  value = "${aws_subnet.subnets.*.cidr_block}"
}