---
layout: post
title:  "Naming Conventions for Azure Resources"
author: "Paulo Thüler"
categories: [ Azure ]
tags: [ Azure ]
image: assets/2025-06-26-azure-naming-convention/naming-convention-avatar.png"
description: "Naming Conventions for Azure Resources"
featured: true
hidden: false
---

> **TL;DR:**
> We've all been there: a quick chat about naming conventions suddenly turns into a full-blown naming symposium. One wants dashes, another swears by PascalCase, and someone always brings up ‘naming things is hard’. This guide won’t end the debates (nothing will), but it will give you a solid, practical approach to naming your Azure resources and resource groups. A clear convention helps with automation, governance, and keeping your cloud chaos in check. Just remember – this is a recommendation, not a religion. Feel free to adapt, adjust, or politely ignore.

- [Overview](#overview)
- [General Principles](#general-principles)
- [Resource Group Naming](#resource-group-naming)
- [Resource Naming](#resource-naming)
  - [Instances](#instances)
- [Special Resource Names](#special-resource-names)
  - [Naming Restrictions](#naming-restrictions)
- [Example](#example)
- [Tags](#tags)
- [Related Links](#related-links)

# Overview
Naming things in Azure is hard, but a clear convention makes your cloud life easier. This guide gives you practical, opinionated patterns for naming Azure resources and resource groups, including how to handle special cases, restrictions, and multiple instances. You’ll find real-world examples, links to official docs, and tips for keeping your environment organized and automation-friendly. Use these rules as a starting point—adapt them to your needs, and don’t be afraid to tweak as your cloud grows.

# General Principles

A naming convention can be imagined as a root structure. The further down it goes, the more variations there are. At each level of the root node, there are equivalent alternatives. It is important to follow this rule and **never break** it.

# Resource Group Naming
All the resources in your resource group should share the same lifecycle ([Microsoft](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/overview#resource-groups)). You deploy, update, and delete them together. If one resource, such as a server, needs to exist on a different deployment cycle it should be in another resource group (workload).

[![Resource Groups](/assets/2025-06-26-azure-naming-convention/naming-convention-resourcegroups.png)](/assets/2025-06-26-azure-naming-convention/naming-convention-resourcegroups.png)

# Resource Naming

[![Resource Naming](/assets/2025-06-26-azure-naming-convention/naming-convention-resource.png)](/assets/2025-06-26-azure-naming-convention/naming-convention-resource.png)

## Instances

Perhaps multiple instances of a resource type are required within a resource group. In such cases, an instance counter can be appended to the name. But as a reminder, do not break the rule of the root structure. Example:

- webflow-preprod-westeurope-avd-hostpool-**001**
- wf-iv7c2daboloe4-kv-**001**

# Special Resource Names

## Naming Restrictions

Azure offers resource types with specific limitations such as storageaccount, keyvault, and compute galleries. These resources require a globally unique name and have character restrictions. To address this, you can use the [`uniqueString()`](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-string#uniquestring) function of bicep / arm. The `resource group id` contains all necessary information (subscriptionid, prefix, stage, region, workload) that defines a globally unique resource on Azure. This id serves as the value for the uniqueString() function.

Example:

| Resource Type  | Code Example                                 | Result                  | Restriction                                                                                                                           |
| -------------- | -------------------------------------------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| storageaccount | ${prefix}${uniqueString(resourceGroup().id)}st   | wf**iv7c2daboloe4**st   | [Microsoft.Storage](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftstorage)   |
| keyvault       | ${prefix}-${uniqueString(resourceGroup().id)}-kv | wf-**iv7c2daboloe4**-kv | [Microsoft.KeyVault](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftkeyvault) |

**NOTE:** The same unique string can be generated with the [AzExpression](https://www.powershellgallery.com/packages/AzExpression) module in PowerShell.

Example (PowerShell):

```powershell
Install-Module AzExpression

New-AzUniqueString -InputStrings "/subscriptions/SUBSCRIPTIONID/resourceGroups/webflow-preprod-westeurope-avd-rg"
```

This will result in the same unique string as the uniqueString() function.

# Example

A typical naming pattern for a storage account might look like:

- `$${prefix}${uniqueString(resourceGroup().id)}st` (e.g., `wfiv7c2daboloe4st`)

Of if you have multiple instances in the same resource group:

- `webflow-preprod-westeurope-avd-hostpool-001`
- `wf-iv7c2daboloe4-kv-001`

# Tags

If it requires additional information on your resource or resource group, Microsoft recommends to use tags to organize your Azure resources. ([Microsoft](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources))

# Related Links
- [Microsoft - Define your naming convention](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Microsoft - Abbreviation recommendations for Azure resources](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Microsoft - Naming rules and restrictions for Azure resources](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
- [Microsoft - Organize your Azure resources effectively](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-setup-guide/organize-resources)

---

For more details or questions, feel free to reach out or open an issue in the repository.