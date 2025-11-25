Pod::Spec.new do |s|
  s.name             = 'LiteMobCXHSDK-iOS'
  s.version          = '1.0.0'
  s.summary          = 'LiteMobCXHSDK - 轻量级移动广告SDK（真机版本）'
  s.description      = <<-DESC
  LiteMobCXHSDK 是一个轻量级的iOS广告SDK，支持横幅广告、插屏广告、原生广告、激励视频、开屏广告等多种广告形式。
  提供简洁的API接口，易于集成，支持隐私合规配置。
  
  ⚠️ 此版本为真机版本，仅支持真机设备，体积更小。
                       DESC

  # TODO: 发布前需要修改以下信息
  s.homepage         = 'https://github.com/your-username/LiteMobCXHSDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :git => 'https://github.com/your-username/LiteMobCXHSDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.requires_arc = true

  # 真机版本 Framework
  s.vendored_frameworks = 'LiteMobCXHSDK/device/LiteMobCXHSDK.framework'
  s.public_header_files = 'LiteMobCXHSDK/device/LiteMobCXHSDK.framework/Headers/*.h'

  # 依赖的系统框架
  s.frameworks = [
    'Foundation',
    'UIKit',
    'CoreLocation',
    'CoreTelephony',
    'SystemConfiguration',
    'AdSupport',
    'AppTrackingTransparency'
  ]

  # 依赖的系统库
  s.libraries = [
    'z',
    'c++'
  ]
end


