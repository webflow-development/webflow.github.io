---
layout: post
title: "Azure Bicep - Infrastructure as Code"
author: "Paulo Thüler"
categories: [ Microsoft Azure, Infrastructure as Code, Cloud ]
tags: [Azure, Bicep]
image: assets/images/bicep.png
description: "Learn about Azure Bicep, a domain-specific language (DSL) for deploying Azure resources declaratively."
featured: true
hidden: false
---

Azure Bicep is a domain-specific language (DSL) that simplifies the authoring experience for Azure Resource Manager (ARM) templates. It provides a more concise syntax and better support for code reuse.

## Key Features

- **Simpler syntax**: Cleaner and easier to read than ARM JSON templates
- **Type safety**: Catch errors before deployment with built-in type validation
- **Module support**: Reuse code through modular template development
- **IDE integration**: Great tooling support with VS Code and IntelliJ
- **Automatic dependency management**: No need to manually specify dependencies

### Basic Example

```bicep
param location string = 'westeurope'
param storageName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
```

Bicep helps you manage Azure infrastructure more efficiently while reducing the complexity and verbosity of JSON-based ARM templates.

