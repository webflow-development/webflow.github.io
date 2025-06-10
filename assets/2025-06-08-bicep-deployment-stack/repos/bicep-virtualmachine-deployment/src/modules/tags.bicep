param location string
param stage string
param prefix string

resource tags 'Microsoft.Resources/tags@2025-03-01' = {
  name: 'default'
  properties: {
    tags: {
      environment: stage
      location: location
      prefix: prefix
    }
  }
}
