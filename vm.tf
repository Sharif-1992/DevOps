resource "azurerm_network_security_group" "nsg" {
  name                = "demo-nsg"
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "AllowOutboundHTTPS"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_virtual_machine_extension" "ama_agent" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  depends_on = [
    azurerm_monitor_data_collection_rule_association.dcr_assoc
  ]
}
resource "azurerm_virtual_network" "vnet" {
  name                = "demo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "demo-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "demo-nic"
  location            = var.primary_location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.example.name
  location            = var.primary_location
  size                = var.vm_size
  admin_username      = var.vm_admin_username

  network_interface_ids = [azurerm_network_interface.nic.id]

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    source = "terraform"
  }
}

/*
Azure Monitor Agent extension removed because the marketplace artifact
was not available in this subscription/region. The Data Collection Rule
association typically triggers AMA deployment automatically; if not,
we can re-add the extension with the correct publisher/type for your region.
*/

# --- Secondary region networking & VM ---
resource "azurerm_virtual_network" "vnet_secondary" {
  name                = "demo-vnet-secondary"
  address_space       = ["10.1.0.0/16"]
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.secondary.name
}

resource "azurerm_subnet" "subnet_secondary" {
  name                 = "demo-subnet-secondary"
  resource_group_name  = azurerm_resource_group.secondary.name
  virtual_network_name = azurerm_virtual_network.vnet_secondary.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_security_group" "nsg_secondary" {
  name                = "demo-nsg-secondary"
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.secondary.name

  security_rule {
    name                       = "AllowOutboundHTTPS"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    source = "terraform"
    region = "secondary"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_secondary" {
  subnet_id                 = azurerm_subnet.subnet_secondary.id
  network_security_group_id = azurerm_network_security_group.nsg_secondary.id
}

resource "azurerm_network_interface" "nic_secondary" {
  name                = "demo-nic-secondary"
  location            = var.secondary_location
  resource_group_name = azurerm_resource_group.secondary.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_secondary.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm_secondary" {
  name                = var.vm_secondary_name
  resource_group_name = azurerm_resource_group.secondary.name
  location            = var.secondary_location
  size                = var.vm_size
  admin_username      = var.vm_admin_username

  network_interface_ids = [azurerm_network_interface.nic_secondary.id]

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    source = "terraform"
    region = "secondary"
  }
}

resource "azurerm_virtual_machine_extension" "ama_agent_secondary" {
  name                       = "AzureMonitorLinuxAgentSecondary"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm_secondary.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  depends_on = [
    azurerm_monitor_data_collection_rule_association.dcr_assoc_secondary
  ]
}

resource "azurerm_monitor_data_collection_rule_association" "dcr_assoc_secondary" {
  name                    = "dcr-assoc-demo-secondary"
  target_resource_id      = azurerm_linux_virtual_machine.vm_secondary.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr_secondary.id
}
