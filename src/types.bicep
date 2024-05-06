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
  args: string[]?
  command: string[]?
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
