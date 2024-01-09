# TODO: insert resources here.
data "azurerm_resource_group" "parent" {
  count = var.location == null ? 1 : 0

  name = var.resource_group_name
}

resource "azurerm_search_service" "this" {
  location            = try(data.azurerm_resource_group.parent[0].location, var.location) # TODO: does this need a try block if theres only one resource?
  name                = "example-resource"
  resource_group_name = var.existing_parent_resource.name # TODO: check if this is defined 
  sku                 = "standard"
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock.kind != "None" ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azurerm_TODO_resource.this.id
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_TODO_resource.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
resource "azurerm_search_service" "this" {
  location                                 = var.search_service_location
  name                                     = var.search_service_name
  resource_group_name                      = var.search_service_resource_group_name
  sku                                      = var.search_service_sku
  allowed_ips                              = var.search_service_allowed_ips
  authentication_failure_mode              = var.search_service_authentication_failure_mode
  customer_managed_key_enforcement_enabled = var.search_service_customer_managed_key_enforcement_enabled
  hosting_mode                             = var.search_service_hosting_mode
  local_authentication_enabled             = var.search_service_local_authentication_enabled
  partition_count                          = var.search_service_partition_count
  public_network_access_enabled            = var.search_service_public_network_access_enabled
  replica_count                            = var.search_service_replica_count
  semantic_search_sku                      = var.search_service_semantic_search_sku
  tags                                     = var.search_service_tags

  dynamic "identity" {
    for_each = var.search_service_identity == null ? [] : [var.search_service_identity]
    content {
      type = identity.value.type
    }
  }
  dynamic "timeouts" {
    for_each = var.search_service_timeouts == null ? [] : [var.search_service_timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

