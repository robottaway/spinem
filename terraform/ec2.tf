data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# resource "aws_instance" "web" {
#   ami           = "${data.aws_ami.ubuntu.id}"
#   instance_type = "t2.micro"
#   key_name = "rob-windoze"
# 
#   subnet_id = "${aws_subnet.pub1.id}"
#   associate_public_ip_address = true
# 
#   tags {
#     Name = "HelloWorld"
#   }
# }
# 
# resource "aws_instance" "db" {
#   ami           = "${data.aws_ami.ubuntu.id}"
#   instance_type = "t2.micro"
#   key_name = "rob-windoze"
# 
#   subnet_id = "${aws_subnet.priv1.id}"
# 
#   tags {
#     Name = "HelloWorldDB"
#   }
# }
