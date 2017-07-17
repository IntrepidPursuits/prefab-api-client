def xcodeProject = new io.intrepid.XcodeProject()
xcodeProject.name = "APIClient"
xcodeProject.sourceDirectory = "Source"
xcodeProject.testDirectory = "Tests"
xcodeProject.addBuild([
  configuration: "Debug",
])

def config = [
  deploy: false,
  slack: [
    enabled: true,
    channel: "#jenkins-ether"
  ]
]

xcodePipeline(this, xcodeProject, config)
