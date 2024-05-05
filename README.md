# .NET Web App Development Environment on Azure

[![Building ARM Template from main Bicep file](https://github.com/mirfire/azure-bicep-training/actions/workflows/arm-build.yaml/badge.svg?branch=main&event=push)](https://github.com/mirfire/azure-bicep-training/actions/workflows/arm-build.yaml)

This repository hosts the necessary Bicep code to deploy a .NET web app on Azure. This is made as an exploration and practice for Bicep, while

## Context

A team needs a simple infrastructure for developing and testing a new product, in Azure. They plan to use a database, and storage. They might also make an API on top of it later.

## Constraints

- Must be accessible from the Internet
- Must be highly available
- Must be replicable
- Must allow for a database to be brought on later

## Possible Solutions

### Container Apps Based (CaaS)

Packaging the code into a container image, then running that image in an Azure-controlled environment.

- Based on containers
  - More portable
  - More flexible
  - Requires packaging

```mermaid
flowchart LR
    internet[Internet]-->|HTTPS Ingress| containerFront
    subgraph vnet [Virtual Network]
        subgraph environment [Container App Environment]
            logAnalytics[Log Analytics]
            containerFront[Front-End Container]
            containerBack[Back-End Container]
            containerFront -->|optional| containerBack
        end
        containerBack -->|optional| database
        database[Azure DB for PGSQL]
        storageAccount[Storage Account]
        containerFront -->|optional| storageAccount
    end
```


### App Service Based (PaaS)

Deploying code directly to an Azure-controlled environment.

```mermaid
flowchart LR
    internet[Internet]-->|HTTPS| serviceAppFront

    subgraph vnet [Virtual Nework]
        subgraph serviceAppPlan[App Service Plan]
            serviceAppFront[Front-End App Service]
            serviceAppBack[Back-End App Service]
            serviceAppFront[Front-End App Service] -->|optional| serviceAppBack
        end
        azDbPGSQL[Azure DB for PGSQL]
        serviceAppFront[Front-End App Service] -->|optional| azDbPGSQL
        azStorageAccount[Storage Account]
        serviceAppFront[Front-End App Service] -->|optional| azStorageAccount
    end
```
