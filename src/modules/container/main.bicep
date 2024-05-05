param name string
param location string
param tags object

param ingressEnabled bool = false
param ingressIsExternal bool = false
param targetPort int = 8080

@description('CPU in cores, must be written as a JSON decimal string')
param cpuCores string = '0.5'
@description('Memory in Gb, must be a ratio of 2 cpuCores')
param memory string = '1Gb'

@minValue(3)
@maxValue(30)
param minReplicas int
@minValue(3)
@maxValue(30)
param maxReplicas int

param environmentID string

param containerImage string

resource containerApp 'Microsoft.App/containerApps@2023-11-02-preview' = {
  location: location
  name: name
  tags: tags
  properties: {
    environmentId: environmentID
    configuration: {
      ingress: (ingressEnabled
        ? {
            external: ingressIsExternal
            targetPort: targetPort
            targetPortHttpScheme: 'http'
          }
        : null)
    }
    template: {
      containers: [
        {
          name: name
          image: containerImage
          resources: {
            cpu: json(cpuCores) // what. Bicep doesn't suppoort floats. See https://github.com/Azure/bicep/issues/5993#issuecomment-1043170716
            memory: memory
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
}
