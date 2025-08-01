locals {
  custom_tags = {
    managed_by   = "terraform"
  }
}

# get Only Availability Zones (no Local Zones):
data "aws_availability_zones" "azs" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# VPC:
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(local.custom_tags,
    {
      Name = "${var.vpc_name}-vpc",
    }
  )
}

########################################################################
#                            Internet GateWay
#######################################################################
# Internet Gateway:
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.custom_tags,
    {
      Name = "${var.vpc_name}-igw",
    }
  )
}

########################################################################
#                         Public Subnets,Routes
########################################################################

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.public_subnets_cidr, count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = merge(local.custom_tags,
    {
      Name = "${var.vpc_name}-public-sub-${format("%02d", count.index + 1)}",
      "kubernetes.io/role/elb" = 1,
    }
  )
}

#Public Route Table:
resource "aws_route_table" "pub_rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc_name}-public-rtb"
  }
}

# IGW Internet public Route:
resource "aws_route" "internet_route_igw" {
  route_table_id         = aws_route_table.pub_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.pub_rtb]
}

# Public Route Table association:
resource "aws_route_table_association" "pub_rtb_assoc" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.pub_rtb.id
}

########################################################################
#                         Private LB,App,DB Subnets,Routes
########################################################################
# Private LB Subnets
resource "aws_subnet" "private_lb_subnets" {
  count             = length(var.private_lb_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_lb_subnets_cidr, count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  tags = merge(local.custom_tags,
    {
      Name                                       = "${var.vpc_name}-prvt-lb-sub-${format("%02d", count.index + 1)}",
      "kubernetes.io/role/internal-elb"          = 1,
    }
  )
}

# Private APP Subnets
resource "aws_subnet" "private_app_subnets" {
  count             = length(var.private_app_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_app_subnets_cidr, count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = merge(local.custom_tags,
    {
      Name                                       = "${var.vpc_name}-prvt-app-sub-${format("%02d", count.index + 1)}",
    }
  )
}

# # Private DB Subnets
resource "aws_subnet" "private_db_subnets" {
  count             = length(var.private_db_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_db_subnets_cidr, count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = merge(local.custom_tags,
    {
      Name                                       = "${var.vpc_name}-prvt-db-sub-${format("%02d", count.index + 1)}",
    }
  )
}

resource "aws_subnet" "private_vpce_subnets" {
  count             = length(var.private_vpce_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_vpce_subnets_cidr,count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = merge(local.custom_tags,
    {
      Name           = "${var.vpc_name}-prvt-vpce-sub-${format("%02d", count.index + 1)}",
    }
  )
}

# Private Route Table:
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = var.tgw_id
  }
  tags = {
    Name = "${var.vpc_name}-private-rtb"
  }
}

# Private Route Table association
resource "aws_route_table_association" "private_rtb_assoc_1" {
  count          = length(var.private_lb_subnets_cidr)
  subnet_id      = aws_subnet.private_lb_subnets[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "private_rtb_assoc_2" {
  count          = length(var.private_app_subnets_cidr)
  subnet_id      = aws_subnet.private_app_subnets[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "private_rtb_assoc_3" {
  count          = length(var.private_vpce_subnets_cidr)
  subnet_id      = aws_subnet.private_vpce_subnets[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "private_rtb_assoc_4" {
  count          = length(var.private_db_subnets_cidr)
  subnet_id      = aws_subnet.private_db_subnets[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}

########################################################################
#                         TGW  Subnets,Routes, TGW Attachement 
########################################################################
# TGW Subnets
resource "aws_subnet" "private_tgw_subnets" {
  count             = length(var.private_tgw_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_tgw_subnets_cidr, count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = merge(local.custom_tags,
    {
      Name = "${var.vpc_name}-prvt-tgw-sub-${format("%02d", count.index + 1)}",
    }
  )
}

#TGW Attachement
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachement" {
  subnet_ids         = aws_subnet.private_tgw_subnets.*.id
  transit_gateway_id = var.tgw_id
  vpc_id             = aws_vpc.vpc.id
  depends_on         = [aws_subnet.private_tgw_subnets]
  tags = merge(local.custom_tags,
    {
      Name           = "${var.vpc_name}-vpc-tgwa",
    }
  )
}

#TGW Route Table:
resource "aws_route_table" "tgw_rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.custom_tags,
    {
      Name = "${var.vpc_name}-tgw-rtb"
    }
  )
}

# TGW Route Table association:
resource "aws_route_table_association" "tgw_rtb_assoc" {
  count          = length(var.private_tgw_subnets_cidr)
  subnet_id      = element(aws_subnet.private_tgw_subnets.*.id, count.index)
  route_table_id = aws_route_table.tgw_rtb.id
}

resource "aws_security_group" "vpce_sg" {
  name        = "${var.vpc_name}-vpce-sg"
  description = "${var.vpc_name}-vpce-sg"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(local.custom_tags,
    {
      Name = "${var.vpc_name}-vpce-sg"
    }
  )
}

resource "aws_security_group_rule" "ingress" {
  description       = "vpce ingress"
  type              = "ingress"
  security_group_id = aws_security_group.vpce_sg.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = [aws_vpc.vpc.cidr_block]
}

resource "aws_security_group_rule" "egress" {
  description       = "vpce egress"
  type              = "egress"
  security_group_id = aws_security_group.vpce_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_vpce_subnets.*.id
  security_group_ids = [
    aws_security_group.vpce_sg.id,
  ]

  tags = merge(local.custom_tags,
    {
      Name = "ec2-vpce"
    }
  )
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_vpce_subnets.*.id
  security_group_ids = [
    aws_security_group.vpce_sg.id,
  ]

  tags = merge(local.custom_tags,
    {
      Name = "ssm-vpce"
    }
  )
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_vpce_subnets.*.id
  security_group_ids = [
    aws_security_group.vpce_sg.id,
  ]

  tags = merge(local.custom_tags,
    {
      Name = "ecr-api-vpce"
    }
  )
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_vpce_subnets.*.id
  security_group_ids = [
    aws_security_group.vpce_sg.id,
  ]

  tags = merge(local.custom_tags,
    {
      Name = "ecr-dkr-vpce"
    }
  )
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.kms"
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_vpce_subnets.*.id
  security_group_ids = [
    aws_security_group.vpce_sg.id,
  ]

  tags = merge(local.custom_tags,
    {
      Name = "kms-vpce"
    }
  )
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private_rtb.id]

  tags = merge(local.custom_tags,
    {
      Name = "s3-vpce"
    }
  )
}