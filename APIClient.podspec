Pod::Spec.new do |s|
  s.name         = "APIClient"
  s.version      = "0.0.1"
  s.summary      = "Prefabricated networking layer for Intrepid."
  s.description  = <<-DESC
                   A lightweight networking layer providing success/failure handling and routing.
                   Optional support for convenient interfacing with object mapping.
                   DESC
  s.homepage     = "https://github.com/IntrepidPursuits/APIClient"
  s.license      = "MIT"
  s.author             = { "Mark Daigneault" => "markd@intrepid.io" }
  s.source       = { :git => "https://github.com/IntrepidPursuits/APIClient.git", :tag => "#{s.version}" }
  s.exclude_files = "tests/**/*"
  s.platform      = :ios
  s.ios.deployment_target = "9.0"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
  s.default_subspec = "Core"

  s.subspec "Core" do |cs|
    cs.source_files = "Source/APIClient/*.swift"
    cs.dependency 'Intrepid', '0.6.6'
  end

  s.subspec "Genome" do |rx|
    rx.source_files = "Source/Genome/*.swift"
    rx.dependency 'Genome', '~> 3.0.0'
  end
end
