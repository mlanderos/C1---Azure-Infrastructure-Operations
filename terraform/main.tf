resource "azurerm_resource_group" "udacityNetwork" {
  name     = local.rg_name
  location = var.location
}

resource "azurerm_network_security_group" "udacityNetwork" {
  name                = "udacity-network-security-group"
  location            = azurerm_resource_group.udacityNetwork.location
  resource_group_name = azurerm_resource_group.udacityNetwork.name
}

resource "azurerm_virtual_network" "udacityNetwork" {
  name                = "udacity-network"
  location            = azurerm_resource_group.udacityNetwork.location
  resource_group_name = azurerm_resource_group.udacityNetwork.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    Udacity = "Project1"
  }
}

resource "azurerm_subnet" "udacity_lb_Network" {
  name                 = "udacity-lb"
  resource_group_name  = azurerm_resource_group.udacityNetwork.name
  virtual_network_name = azurerm_virtual_network.udacityNetwork.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "udacity_be_Network" {
  name                 = "udacity-backend"
  resource_group_name  = azurerm_resource_group.udacityNetwork.name
  virtual_network_name = azurerm_virtual_network.udacityNetwork.name
  address_prefixes     = ["10.0.2.0/24"]
}

### Security Group & Rules
resource "azurerm_network_security_group" "udacity_NSG" {
  name                = "udacitySecurityGroup1"
  location            = azurerm_resource_group.udacityNetwork.location
  resource_group_name = azurerm_resource_group.udacityNetwork.name
}

resource "azurerm_network_security_rule" "udacity_NSG_rule1" {
  name                        = "Allow http traffic from udacity_lb to udacitcy_be"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_ranges          = ["80","443"]
  destination_port_range      = "*"
  source_address_prefixes     = azurerm_subnet.udacity_lb_Network.address_prefixes
  destination_address_prefixes  = azurerm_subnet.udacity_be_Network.address_prefixes
  resource_group_name         = azurerm_resource_group.udacityNetwork.name
  network_security_group_name = azurerm_network_security_group.udacity_NSG.name
}

resource "azurerm_network_security_rule" "udacity_NSG_rule2" {
  name                        = "Allow http traffic between udacity_be to udacitcy_be"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_ranges          = ["80","443"]
  destination_port_range      = "*"
  source_address_prefixes       = azurerm_subnet.udacity_be_Network.address_prefixes
  destination_address_prefixes  = azurerm_subnet.udacity_be_Network.address_prefixes
  resource_group_name         = azurerm_resource_group.udacityNetwork.name
  network_security_group_name = azurerm_network_security_group.udacity_NSG.name
}

resource "azurerm_network_security_rule" "udacity_NSG_rule3" {
  name                        = "Deny incoming traffic from Internet"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.udacityNetwork.name
  network_security_group_name = azurerm_network_security_group.udacity_NSG.name
}


#### LB
resource "azurerm_public_ip" "udacity_lb_ip" {
  name                = "PublicIPForLB"
  location            = azurerm_resource_group.udacityNetwork.location
  resource_group_name = azurerm_resource_group.udacityNetwork.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "udacity_lb" {
  name                = "Udacity-LoadBalancer"
  location            = azurerm_resource_group.udacityNetwork.location
  resource_group_name = azurerm_resource_group.udacityNetwork.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.udacity_lb_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "udacity_lb_be_address_pool" {
  loadbalancer_id = azurerm_lb.udacity_lb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface" "udacityNetwork" {
  name                = "udacity-nic"
  location            = azurerm_resource_group.udacityNetwork.location
  resource_group_name = azurerm_resource_group.udacityNetwork.name

  ip_configuration {
    name                          = "backend"
    subnet_id                     = azurerm_subnet.udacity_be_Network.id
    private_ip_address_allocation = "Dynamic"
  }
}

data "azurerm_resource_group" "image" {
  name = "packer-rg"
}

data "azurerm_image" "image" {
  name                = "myPackerImage"
  resource_group_name = data.azurerm_resource_group.image.name
}

resource "azurerm_linux_virtual_machine_scale_set" "udacity-vmss" {
  name                = "vmscaleset"
  location            = var.location
  resource_group_name = azurerm_resource_group.udacityNetwork.name
  sku                 = "Standard_DS1_v2"
  instances           = var.total_vms

  source_image_id = data.azurerm_image.image.id
  

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  data_disk {
    caching = "None"
    create_option = "Empty"
    disk_size_gb = "5"
    lun = 1
    storage_account_type = "Standard_LRS"
  }

  computer_name_prefix = "udacity-"
  disable_password_authentication = "false"
  admin_username       = var.username
  admin_password       = var.password
  
    network_interface {
      name = "be-nic"
      primary = true
      
      ip_configuration {
        name                                   = "IPConfiguration"
        subnet_id                              = azurerm_subnet.udacity_be_Network.id
        load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.udacity_lb_be_address_pool.id]
        primary = true
      }
    }
}