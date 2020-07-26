
resource "aws_eip" "nat-gw" {
    vpc      = true
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat-gw.id
  subnet_id     = aws_subnet.private-1.id

  depends_on = [aws_eip.nat-gw]
}

