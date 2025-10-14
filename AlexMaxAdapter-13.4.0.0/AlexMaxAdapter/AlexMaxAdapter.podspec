#
# Be sure to run `pod lib lint TopOnTest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AlexMaxAdapter'
  s.version          = '13.4.0.0'
  s.summary          = 'AlexMaxAdapter'
  s.description      = <<-DESC
  AlexMaxAdapter,AlexMaxAdapter.podspec,AlexMaxAdapter.podspec
                       DESC
  s.homepage         = 'https://github.com/GPPG/topon_pod_test.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'GUO PENG' => 'ios' }
  s.source           = { :git => 'https://github.com/GPPG/topon_pod_test.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '12.0'
#  s.swift_version         = '5.0'
  s.static_framework = true
  
  s.requires_arc = true

  s.frameworks = 'SystemConfiguration','CoreGraphics','Foundation','UIKit','AVFoundation','AdSupport','AudioToolbox','CoreMedia','StoreKit','WebKit','AppTrackingTransparency','CoreMotion','CoreTelephony','MessageUI','SafariServices','CoreLocation','MediaPlayer','JavaScriptCore','CoreAudio','CoreFoundation','QuartzCore','NetworkExtension','Accelerate','CoreImage','CoreText','ImageIO','MapKit','MobileCoreServices','Security'
  
  s.pod_target_xcconfig =   {'OTHER_LDFLAGS' => ['-lObjC']}
  
  s.libraries = 'c++', 'z', 'sqlite3', 'xml2', 'resolv','bz2.1.0','bz2','resolv.9','iconv','c++abi'

  s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 armv7s arm64' }

  s.dependency  'AppLovinSDK','13.4.0'
  s.dependency  'AnyThinkiOS','6.5.31'
 
end
