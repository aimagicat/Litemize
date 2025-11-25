Pod::Spec.new do |s|
  s.name             = 'LiteMobCXHSDK-Simulator'
  s.version          = '1.0.0'
  s.summary          = 'LiteMobCXHSDK - 轻量级移动广告SDK（模拟器版本）'
  s.description      = <<-DESC
  LiteMobCXHSDK 是一个轻量级的iOS广告SDK，支持横幅广告、插屏广告、原生广告、激励视频、开屏广告等多种广告形式。
  提供简洁的API接口，易于集成，支持隐私合规配置。
  
  ⚠️ 此版本为模拟器版本，仅支持模拟器，用于开发调试。
                       DESC

  # TODO: 发布前需要修改以下信息
  s.homepage         = 'https://github.com/aimagicat/Litemize'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :git => 'https://github.com/aimagicat/Litemize.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '13.0'
  s.requires_arc = true

  # 模拟器版本 Framework
  s.vendored_frameworks = 'LiteMobCXHSDK/simulator/LiteMobCXHSDK.framework'
  # 注意：使用 vendored_frameworks 时，Framework 的头文件会自动暴露，不需要指定 public_header_files

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


