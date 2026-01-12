Pod::Spec.new do |s|
  s.name             = 'LMSigmobAdapter'
  s.version          = '5.0.4'
  s.summary          = 'LMSigmobAdapter - LitemizeSDK 的 ToBid 适配器'
  s.description      = <<-DESC
  LMSigmobAdapter 是 LitemizeSDK 的第三方广告平台适配器，用于将 LitemizeSDK 接入到 ToBid SDK。
                       DESC

  # TODO: 发布前需要修改以下信息
  s.homepage         = 'https://github.com/aimagicat/Litemize'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Litemob' => 'shibao@litemob.com' }
  s.source           = { :git => 'https://github.com/aimagicat/Litemize.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '11.0'
  s.requires_arc = true

  # 源码
  s.source_files = 'LMSigmobAdapter/**/*.{h,m}'
  s.public_header_files = 'LMSigmobAdapter/**/*.h'
  # 依赖的第三方库
  s.dependency 'LitemizeSDK', '~> 5.0.4'
  # ToBid-iOS SDK 作为依赖声明，但不打包进 framework
  # 使用者（主应用）需要自行引入 ToBid-iOS SDK，避免类冲突
  # 注意：这里使用前向声明，实际使用时需要导入 ToBid SDK 的头文件
  s.dependency 'ToBid-iOS', '~> 4.6.85'
  
  # 依赖的系统框架
  s.frameworks = [
    'Foundation',
    'UIKit'
  ]
  
  # 配置编译选项：允许非模块化头文件
  s.pod_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    # 确保能找到 LitemizeSDK 的头文件
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/LitemizeSDK"',
    # 排除 x86_64 架构（如果 xcframework 不支持）
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
  
  # 注意：ToBid-iOS 包含静态链接的二进制文件
  # 提交到 CocoaPods Trunk 时需要使用 --use-libraries 标志
  # 使用者的 Podfile 中建议使用：use_frameworks! :linkage => :static

end

