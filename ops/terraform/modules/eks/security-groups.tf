resource "aws_security_group" "eks_mgmt" {
  name   = "eks_mgmt"
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.30.0.0/16",
      "172.31.0.0/16"
    ]
  }
}
