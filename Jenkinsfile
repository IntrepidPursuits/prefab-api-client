def xcodeProject = new io.intrepid.XcodeProject()
xcodeProject.name = "APIClient"
xcodeProject.sourceDirectory = "Source"
xocdeProject.testDirectory = "Tests"
xcodeProject.addBuild([
  configuration: "Debug",
])

def config = [
  slack: [
    enabled: true,
    channel: "#jenkins-ether"
  ]
]
