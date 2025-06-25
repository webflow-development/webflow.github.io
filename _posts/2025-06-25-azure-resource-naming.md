---
layout: post
title:  "Naming Conventions for Azure Resources"
author: "Paulo Thüler"
categories: [ Azure ]
tags: [ Azure ]
image: ""
description: "Naming Conventions for Azure Resources"
featured: false
hidden: true
---

> **TL;DR:**
> This article provides practical naming conventions for Azure resources and resource groups, including special cases, restrictions, and best practices. It includes examples, links to official documentation, and guidance for organizing resources at scale.

- [Overview](#overview)
- [Naming Solution](#naming-solution)
  - [General Principles](#general-principles)
  - [Resource Group Naming](#resource-group-naming)
  - [Resource Naming](#resource-naming)
  - [Special Resource Names](#special-resource-names)
    - [Naming Restrictions](#naming-restrictions)
    - [Instances](#instances)
- [Tags](#tags)
- [Example](#example)
- [Related Links](#related-links)

# Overview

This guide describes recommended naming conventions for Azure resources and resource groups. Following a consistent naming strategy helps with resource management, automation, and compliance.

# Naming Solution

## General Principles

A naming convention can be imagined as a root structure. The further down it goes, the more variations there are. At each level of the root node, there are equivalent alternatives. It is important to follow this rule and **never break** it.

## Resource Group Naming
All the resources in your resource group should share the same lifecycle ([Microsoft](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview#resource-groups)). You deploy, update, and delete them together. If one resource, such as a server, needs to exist on a different deployment cycle it should be in another resource group (workload).

![Resource Groups](https://gitlab.com/diemobiliar/swe/bic/system/bic-system-stack-doc/-/raw/main/docs/modules/ROOT/images/namingconvention-resourcegroups.png?ref_type=heads)

## Resource Naming

![Resource Naming](https://gitlab.com/diemobiliar/swe/bic/system/bic-system-stack-doc/-/raw/main/docs/modules/ROOT/images/namingconvention-resources.png?ref_type=heads)

## Special Resource Names

### Naming Restrictions

Azure offers resource types with specific limitations such as storageaccount, keyvault, and compute galleries. These resources require a globally unique name and have character restrictions. To address this, you can use the [`uniqueString()`](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-string#uniquestring) function of bicep / arm. The **resource group id** contains all necessary information (subscriptionid, appid, stage, region, workload) that defines a globally unique resource on Azure. This id serves as the value for the uniqueString() function. (e.g. `/subscriptions/96ac4623-ffd6-4b0f-b41b-bad06a690f82/resourceGroups/wsv-preprod-westeurope-network-avd-rg`)

Example:

| Resource Type   | Code Example                              | Result                    | Restriction                                                                                                                                         |
|-----------------|-------------------------------------------|---------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
| storageaccount  | appid${uniqueString(resourceGroup().id)}st | wsv**iv7c2daboloe4**st    | [Microsoft.Storage](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftstorage)                 |
| keyvault        | appid-${uniqueString(resourceGroup().id)}-kv | wsv-**iv7c2daboloe4**-kv | [Microsoft.KeyVault](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftkeyvault)               |

**NOTE:** The same unique string can be generated with the AzExpression module in PowerShell.

Example (PowerShell):

```powershell
Install-Module AzExpression

New-AzUniqueString -InputStrings "/subscriptions/96ac4623-ffd6-4b0f-b41b-bad06a690f82/resourceGroups/wsv-preprod-westeurope-network-avd-rg"
```

This will result in the same unique string as the uniqueString() function.

### Instances

Perhaps multiple instances of a resource type are required within a resource group. In such cases, an instance counter can be appended to the name. But as a reminder, do not break the rule of the root structure. Example:

- wsv-preprod-westeurope-customimage-mi-**001**
- wsv-iv7c2daboloe4-kv-**001**

# Tags

If it requires additional information on your resource or resource group, Microsoft recommends to use tags to organize your Azure resources. ([Microsoft](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources))

# Example

A typical naming pattern for a storage account might look like:

- `appid${uniqueString(resourceGroup().id)}st` (e.g., `wsviv7c2daboloe4st`)

For multiple instances:

- `wsv-preprod-westeurope-customimage-mi-001`
- `wsv-iv7c2daboloe4-kv-001`

# Related Links
- [Microsoft - Define your naming convention](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Microsoft - Abbreviation recommendations for Azure resources](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Microsoft - Naming rules and restrictions for Azure resources](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
- [Microsoft - Organize your Azure resources effectively](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-setup-guide/organize-resources)
