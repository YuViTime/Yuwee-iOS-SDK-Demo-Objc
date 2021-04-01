source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'

# Uncomment the next line if you're using Swift or would like to use dynamic frameworks
use_frameworks!

def import_pods
    
    # Pods for YuWee SDK
    pod 'Socket.IO-Client-Swift', '~> 15.2.0'
    
    # AWS pods
    pod 'AWSS3', '~> 2.12.0' # For file transfers
    pod 'AWSMobileClient', '~> 2.12.0'
    
    # MessageKit
    pod 'MessageKit'
    
    pod 'SwiftyJSON', '~> 4.0'
    
    pod 'Kingfisher', '~> 6.0'
    
    pod 'MMWormhole', '~> 2.0.0'
    
    # Firebase Pods
    #pod 'Firebase/Core'
    #pod 'Firebase/Database'
    #pod 'Firebase/Crashlytics'
    #pod 'Firebase/Analytics'
    #pod 'Fabric', '~> 1.10.2'
    #pod 'Crashlytics', '~> 3.14.0'
    
end

target 'YuWee SDK' do
    import_pods
end

target 'notification' do
   pod 'Socket.IO-Client-Swift', '~> 15.2.0'
   
 #  post_install do |installer|
  #     installer.pods_project.targets.each do |target|
  #         target.build_configurations.each do |config|
  #             config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = '$(inherited) GTM_BACKGROUND_UIAPPLICATION=0'
   #        end
  #     end
 #  end
end

target 'ScreenShare' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Socket.IO-Client-Swift', '~> 15.2.0'
  pod 'MMWormhole', '~> 2.0.0'
  pod 'SwiftyJSON', '~> 4.0'
  # Pods for ScreenShare
end

#post_install do | installer |
#
#    # disables bit code
#    installer.pods_project.targets.each do |target|
#        installer.pods_project.build_configurations.each do |config|
#            config.build_settings['ENABLE_BITCODE'] = 'YES'
#        end
#
#        target.build_configurations.each do |config|
#            config.build_settings['ENABLE_BITCODE'] = 'YES'
#        end
#    end
#end

