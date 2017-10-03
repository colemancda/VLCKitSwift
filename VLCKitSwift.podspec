Pod::Spec.new do |s|
  s.name         = "VLCKitSwift"
  s.version      = "0.1"
  s.summary      = "Pure Swift library for libVLC (Linux compatible)"
  s.description  = "Pure Swift library for libVLC"
  s.homepage     = "https://github.com/colemancda/VLCKitSwift"
  s.license      = { :type => "LGPL-2.1", :file => "LICENSE" }
  s.author             = { "Alsey Coleman Miller" => "alseycmiller@gmail.com" }
  s.social_media_url   = ""
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/colemancda/VLCKitSwift.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
  s.dependency 'MobileVLCKit'
  s.ios.xcconfig = { 
    'ENABLE_BITCODE' => 'NO',
    'SWIFT_INCLUDE_PATHS' => '$SRCROOT/../libVLC/include'
   }
  s.user_target_xcconfig = { 
    'ENABLE_BITCODE' => 'NO',
    'SWIFT_INCLUDE_PATHS' => '$SRCROOT/../libVLC/include'
   }
end
