import { arrayString, ContainerApp, ContainerApps } from '../../types.bicep'

param name string
param location string
param tags object

@description('ID for the managed environment')
param environmentID string

param container ContainerApp

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  location: location
  name: name
  tags: tags
  properties: {
    environmentId: environmentID
    configuration: {
      ingress: (container.ingress.ingressEnabled
        ? {
            external: container.ingress.ingressIsExternal
            targetPort: container.ingress.targetPort
          }
        : null)
    }
    template: {
      containers: [
        {
          name: container.name
          image: container.image
          resources: {
            cpu: json(container.resources.cpuCores) // what. Bicep doesn't suppoort floats. See https://github.com/Azure/bicep/issues/5993#issuecomment-1043170716
            memory: container.resources.memory
          }
        }
      ]
      scale: {
        minReplicas: container.scaling.minReplicas
        maxReplicas: container.scaling.maxReplicas
      }
    }
  }
}
