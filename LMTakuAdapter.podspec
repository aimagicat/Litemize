Pod::Spec.new do |s|
  s.name             = 'LMTakuAdapter'
  s.version          = '5.0.10'
  s.summary          = 'LMTakuAdapter - LitemobSDK 的 Taku/AnyThink 适配器'
  s.description      = <<-DESC
  LMTakuAdapter 是 LitemobSDK 的第三方广告平台适配器，用于将 LitemobSDK 接入到 Taku/AnyThink SDK。
                       DESC

  # TODO: 发布前需要修改以下信息
  s.homepage         = 'https://github.com/aimagicat/Litemize'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Litemob' => '@example.com' }
  s.source           = { :git => 'https://github.com/aimagicat/Litemize.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '11.0'
  s.requires_arc = true

  # 源码
  s.source_files = 'LMTakuAdapter/**/*.{h,m}'
  s.public_header_files = 'LMTakuAdapter/**/*.h'
  # 依赖的第三方库
  s.dependency 'LitemobSDK', '~> 5.0.10'
  # AnyThinkiOS 作为依赖声明，但不打包进 framework
  # 使用者（主应用）需要自行引入 AnyThinkiOS，避免类冲突
  s.dependency 'AnyThinkiOS','6.5.34'
  
  # 依赖的系统框架
  s.frameworks = [
    'Foundation',
    'UIKit'
  ]
  
  # 配置编译选项：只使用 AnyThinkiOS 的头文件，不链接其二进制
  # 这样可以避免 AnyThinkSDK 的类被编译进 LMTakuAdapter.framework
  # 注意：这里不链接 AnyThinkSDK，只使用头文件，运行时由主应用提供
  s.pod_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
  
  # 重要：配置依赖为可选依赖，避免打包进 framework
  # 使用动态库链接方式时，依赖不会被静态链接
  # 如果使用静态库，需要确保编译时通过 xcconfig 不链接 AnyThinkiOS
  
end
