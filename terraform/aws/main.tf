resource "aws_vpc" "vpc10" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"
    tags = {
        Name = "vpc10"
    }
}

resource "aws_vpc" "vpc20" {
    cidr_block           = "20.0.0.0/16"
    enable_dns_hostnames = "true"
    tags = {
        Name = "vpc20"
    }
}

resource "aws_subnet" "sn_vpc10_pub" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "sn_vpc10"
    }
}

resource "aws_subnet" "sn_vpc20_priv" {
    vpc_id            = aws_vpc.vpc20.id
    cidr_block        = "20.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "sn_vpc20"
    }
}

resource "aws_vpc_peering_connection" "vpc_peering" {
    peer_vpc_id   = aws_vpc.vpc20.id
    vpc_id        = aws_vpc.vpc10.id
    auto_accept   = true  
    tags = {
        Name = "vpc_peering"
    }
}

resource "aws_internet_gateway" "igw_vpc10" {
    vpc_id = aws_vpc.vpc10.id
    tags = {
        Name = "igw_vpc10"
    }
}

resource "aws_route_table" "rt_sn_vpc10_pub" {
    vpc_id = aws_vpc.vpc10.id
    route {
        cidr_block = "20.0.0.0/16"
        gateway_id = aws_vpc_peering_connection.vpc_peering.id
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc10.id
    }
    tags = {
        Name = "rt_sn_vpc10_pub"
    }
}

resource "aws_route_table" "rt_sn_vpc20_priv" {
    vpc_id = aws_vpc.vpc20.id
    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = aws_vpc_peering_connection.vpc_peering.id
    }
    tags = {
        Name = "rt_sn_vpc20_priv"
    }
}

resource "aws_route_table_association" "rt_sn_vpc10_pub_To_sn_vpc10_pub" {
  subnet_id      = aws_subnet.sn_vpc10_pub.id
  route_table_id = aws_route_table.rt_sn_vpc10_pub.id
}

resource "aws_route_table_association" "rt_sn_vpc20_priv_To_sn_vpc20_priv" {
  subnet_id      = aws_subnet.sn_vpc20_priv.id
  route_table_id = aws_route_table.rt_sn_vpc20_priv.id
}

resource "azurerm_virtual_network_peering" "vnet10-to-vnet20" {
  name                = "vnet10-to-vnet20"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet10.name
  remote_virtual_network_id = azurerm_virtual_network.vnet20.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "vnet20-to-vnet10" {
  name                = "vnet20-to-vnet10"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet20.name
  remote_virtual_network_id = azurerm_virtual_network.vnet10.id
  allow_virtual_network_access = true
}