targetScope = 'subscription'

param location string
param stage string
param prefix string

param vmSize string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${prefix}-${stage}-${location}-virtualmachine-rg'
  location: location
}

module tags 'modules/tags.bicep' = {
  name: 'tags'
  scope: resourceGroup
  params: {
    prefix: prefix
    stage: stage
    location: location
  }
}

module virtualNetwork 'modules/virtualnetwork.bicep' = {
  name: 'virtualNetwork'
  scope: resourceGroup
  params: {
    location: location
    virtualNetworkName: '${prefix}-${uniqueString(resourceGroup.id)}-vnet'
    publicIPAdressName: '${prefix}-${uniqueString(resourceGroup.id)}-pip'
    networkSecurityGroupName: '${prefix}-${uniqueString(resourceGroup.id)}-nsg'
  }
}

module virtualMachine 'modules/virtualmachine.bicep' = {
  name: 'virtualMachine'
  scope: resourceGroup
  params: {
    location: location
    virtualMachineName: '${prefix}-${uniqueString(resourceGroup.id)}-vm'
    vmSize: vmSize
    storageAccountType: 'StandardSSD_LRS'
    imageRefrence: {
      publisher: 'microsoftwindowsdesktop'
      offer: 'windows-11'
      sku: 'win11-24h2-pro'
      version: 'latest'
    }
    adminUsername: 'svadmin'
    adminPassword: 'Welcome123!'
    computerName: toUpper('${prefix}VM')
    networkInterfaceName: '${prefix}-${uniqueString(resourceGroup.id)}-nic'
    networkSecurityGroupResourceId: virtualNetwork.outputs.networkSecurityGroupResourceId
    publicIPAddressesResourceId: virtualNetwork.outputs.publicIPAddressResourceId
    subnetResourceId: virtualNetwork.outputs.subnetResourceId
  }
}
