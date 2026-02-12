Pod::Spec.new do |s|
  s.name             = 'LitemobSDK'
  s.version          = '5.0.10'
  s.summary          = 'LitemobSDK - 轻量级移动广告SDK'
  s.description      = <<-DESC
  LitemobSDK 是一个轻量级的iOS广告SDK，支持横幅广告、插屏广告、原生广告、激励视频、开屏广告等多种广告形式。
  提供简洁的API接口，易于集成，支持隐私合规配置。
                       DESC

  # TODO: 发布前需要修改以下信息
  s.homepage         = 'https://github.com/aimagicat/Litemize'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Litemob' => 'shibao@litemob.com' }
  s.source           = { :git => 'https://github.com/aimagicat/Litemize.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '11.0'
  s.requires_arc = true

  s.vendored_frameworks = 'LitemobSDK.xcframework'

  # 依赖的系统框架（必需）
  s.frameworks = [
    'Foundation',
    'WebKit',
    # 视频
    'AVFoundation',
    'UIKit'
  ]
  
  # 弱链接的系统框架（如果宿主应用存在则使用，不存在则优雅降级）
  s.weak_frameworks = [
    'CoreLocation',        # 地理位置信息（SDK 内部已做可用性检查）
    'CoreTelephony',      # 运营商信息（SDK 内部已做降级处理）
    'AdSupport',          # 广告标识符（SDK 内部已做运行时检查）
    'AppTrackingTransparency'  # 跟踪权限（SDK 内部已做可用性检查）
  ]

  # 依赖的系统库
  s.libraries = [
    'z',
    'c++'
  ]
end

