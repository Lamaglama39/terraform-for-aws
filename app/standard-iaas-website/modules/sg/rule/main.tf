resource "aws_security_group_rule" "this" {
  security_group_id = var.sg_rules.security_group_id
  for_each          = { for idx, rule in var.sg_rules.rule : idx => rule }

  type      = each.value.type
  from_port = each.value.from_port
  to_port   = each.value.to_port
  protocol  = each.value.protocol

  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
}
