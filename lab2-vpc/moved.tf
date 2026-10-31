moved {
  from = aws_subnet.public_a
  to   = aws_subnet.public["a"]
}
moved {
  from = aws_subnet.public_b
  to   = aws_subnet.public["b"]
}
moved {
  from = aws_subnet.private_a
  to   = aws_subnet.private["a"]
}
moved {
  from = aws_subnet.private_b
  to   = aws_subnet.private["b"]
}
moved {
  from = aws_route_table_association.lab2_private_subnet_1_assoc
  to   = aws_route_table_association.lab2_private_subnet_assoc["a"]
}
moved {
  from = aws_route_table_association.lab2_private_subnet_2_assoc
  to   = aws_route_table_association.lab2_private_subnet_assoc["b"]
}
moved {
  from = aws_route_table_association.lab2_public_subnet_1_assoc
  to   = aws_route_table_association.lab2_public_subnet_assoc["a"]
}
moved {
  from = aws_route_table_association.lab2_public_subnet_2_assoc
  to   = aws_route_table_association.lab2_public_subnet_assoc["b"]
}
