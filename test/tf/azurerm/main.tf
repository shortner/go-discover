provider "azurerm" {
  version = "~> 1.3"
}

provider "random" {
  version = "~> 1.2"
}

variable "prefix" {
  default = "go-discover"
}

resource "azurerm_resource_group" "test" {
  name     = "${var.prefix}-dev"
  location = "West Europe"
}

module "network" {
  source              = "./modules/network"
  name                = "${var.prefix}-internalnw"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
  address_space       = "10.0.0.0/16"
  subnet_cidr         = "10.0.1.0/24"
}

module "vm01" {
  source              = "./modules/virtual_machine"
  name                = "${var.prefix}-01"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
  subnet_id           = "${module.network.subnet_id}"

  tags {
    "consul" = "server"
  }
}

module "vm02" {
  source              = "./modules/virtual_machine"
  name                = "${var.prefix}-02"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
  subnet_id           = "${module.network.subnet_id}"

  tags {
    "consul" = "server"
  }
}

// We intentionally don't tag the last machine to ensure we only discover the
// first two
module "vm03" {
  source              = "./modules/virtual_machine"
  name                = "${var.prefix}-03"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
  subnet_id           = "${module.network.subnet_id}"
}
