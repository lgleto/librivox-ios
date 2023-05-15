# Uncomment the next line to define a global platform for your project
  platform :ios, '13.3.1'

target 'LibriVox' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for LibriVox
  pod 'SwaggerClient', :path => './swagger-ios'
  pod 'SSZipArchive'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.3'
               end
          end
   end
end