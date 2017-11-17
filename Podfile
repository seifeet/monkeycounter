source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'MonkeyCounter' do

    # pod 'DATASource', :git => 'https://github.com/3lvis/DATASource.git'
    pod 'Swinject', '~> 2.0.0'
    pod 'SwinjectStoryboard', '~> 1.0.0'

    # a lightweight and fully customizable alert and notification view
    pod 'SwiftMessages'

    # A fast & simple, yet powerful & flexible logging framework for Mac and iOS.
    pod 'XCGLogger', '~> 5.0.1'

    # A chat view controller
    pod 'JSQMessagesViewController'

    # Functional Reactive Programming
    pod 'ReactiveCocoa', '~> 5.0.0'

    # a lightweight, yet powerful, color framework
    pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'

    # a UIViewController subclass that allows to select a location on a map
    pod 'LocationPicker'

    # image resizing
    pod 'Toucan'

end

developer_info = {
  "DevelopmentTeam" => "Monkeys",
  "DevelopmentTeamName" => "AT"
}

#
#  hopefully a temporary fix for Swift3
#
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
