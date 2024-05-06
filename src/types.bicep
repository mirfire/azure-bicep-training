@export()
@description('An array of string')
type arrayString = string[]

@export()
@description('Environment variables for a container')
type environmentVariable = {
  name: string
  value: string
}

@export()
@description('Object representing an abstracted Container App')
type ContainerApp = {
  name: string
  image: string
  args: arrayString?
  command: arrayString?
  envVars: environmentVariable[]?
  scaling: {
    @minValue(3)
    @maxValue(30)
    minReplicas: int
    @minValue(3)
    @maxValue(30)
    maxReplicas: int
  }
  resources: {
    @description('CPU in cores, must be written as a JSON decimal in a string')
    cpuCores: string
    @description('Memory in Gb, must be a ratio of x2 cpuCores')
    memory: string
  }
  ingress: {
    external: bool
    targetPort: int
  }?
  volumeMounts: [
    {
      volumeName: string
      mountPath: string
    }
  ]?
}

@export()
type ContainerApps = ContainerApp[]
