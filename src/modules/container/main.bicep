import { ContainerApp } from '../../types.bicep'

param name string
param location string
param tags object

@description('ID for the managed environment')
param environmentID string

@description('Container to deploy')
param container ContainerApp

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    environmentId: environmentID
    configuration: {
      ingress: container.ingress
    }
    template: {
      containers: [
        {
          name: container.name
          image: container.image
          volumeMounts: container.volumeMounts
          resources: {
            cpu: json(container.resources.cpuCores)
            memory: container.resources.memory
          }
        }
      ]
      volumes: [
        // container.volumeMounts might be null 
        for volume in container.volumeMounts!: {
          name: volume.volumeName
          storageName: '${volume.volumeName}storage'
          storageType: 'AzureFile'
        }
      ]
      scale: {
        minReplicas: container.scaling.minReplicas
        maxReplicas: container.scaling.maxReplicas
      }
    }
  }
}
