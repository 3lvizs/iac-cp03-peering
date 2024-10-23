resource "azurerm_resource_group" "rg" {
  name     = "rg-iac-cp03"
  location = "brazilsouth"
}

resource "azurerm_virtual_network" "vnet10" {
  name                = "vnet10"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "vnet20" {
  name                = "vnet20"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["20.0.0.0/16"]
}

resource "azurerm_subnet" "subnet-public" {
  name                 = "subnet-public"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet10.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet-private" {
  name                 = "subnet-private"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet20.name
  address_prefixes     = ["20.0.1.0/24"]
}

resource "azurerm_route_table" "public_rt" {
  name                = "public-route-table"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_route" "public_route" {
  name                  = "default-route"
  resource_group_name   = azurerm_resource_group.rg.name
  route_table_name      = azurerm_route_table.public_rt.name
  address_prefix        = "0.0.0.0/0"
  next_hop_internet = "Internet"
}

resource "azurerm_subnet_route_table_association" "subnet_public_association" {
  subnet_id      = azurerm_subnet.subnet-public.id
  route_table_id = azurerm_route_table.public_rt.id
}