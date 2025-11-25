Pod::Spec.new do |s|
    s.name             = 'LiteMobCXHSDK'
    s.version          = '1.0.0'
    s.summary          = 'LiteMobCXHSDK - 轻量级移动广告SDK'
    s.description      = <<-DESC
    LiteMobCXHSDK 是一个轻量级的iOS广告SDK，支持横幅广告、插屏广告、原生广告、激励视频、开屏广告等多种广告形式。
    提供简洁的API接口，易于集成，支持隐私合规配置。
    
    ⚠️ 此版本使用预编译 Framework，源代码不会公开。
                         DESC
  
    # TODO: 发布前需要修改以下信息
    s.homepage         = 'https://github.com/aimagicat/Litemize'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Your Name' => 'your.email@example.com' }
    s.source           = { :git => 'https://github.com/aimagicat/Litemize.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '13.0'
    s.requires_arc = true
  
    # 使用预编译的 Framework（默认使用 Universal 版本，同时支持真机和模拟器）
    # 如需使用其他版本，请使用：
    # - pod 'LiteMobCXHSDK-iOS'        # 真机版本
    # - pod 'LiteMobCXHSDK-Simulator' # 模拟器版本
    # - pod 'LiteMobCXHSDK-Universal' # Universal版本（与此相同）
    s.vendored_frameworks = 'LiteMobCXHSDK/universal/LiteMobCXHSDK.framework'
    
    # Framework 头文件路径
    s.public_header_files = 'LiteMobCXHSDK/universal/LiteMobCXHSDK.framework/Headers/*.h'
    
    # 如果 Framework 的头文件在 Headers 目录下
    # s.source_files = 'LiteMobCXHSDK/LiteMobCXHSDK.framework/Headers/*.h'
    
    # 资源文件（如果 Framework 中包含资源）
    # 方式一：如果资源在 Framework 内部，通常不需要单独配置
    # 方式二：如果资源需要单独打包
    # s.resource_bundles = {
    #   'LiteMobCXHSDK' => ['LiteMobCXHSDK/Assets.xcassets']
    # }
  
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
  
    # 如果需要依赖其他 CocoaPods 库
    # s.dependency 'SomeLibrary', '~> 1.0'
  end
  
  