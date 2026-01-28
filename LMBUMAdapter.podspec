Pod::Spec.new do |s|
  s.name             = 'LMBUMAdapter'
  s.version          = '5.0.7'
  s.summary          = 'LMBUMAdapter - LitemobSDK 的穿山甲（BUM）适配器'
  s.description      = <<-DESC
  LMBUMAdapter 是 LitemobSDK 的第三方广告平台适配器，用于将 LitemobSDK 接入到穿山甲（BUM）SDK。
  
                       DESC

  # TODO: 发布前需要修改以下信息
  s.homepage         = 'https://github.com/aimagicat/Litemize'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Litemob' => 'shibao@litemob.com' }
  s.source           = { :git => 'https://github.com/aimagicat/Litemize.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '11.0'
  s.requires_arc = true

  # 源码
  s.source_files = 'LMBUMAdapter/**/*.{h,m}'
  s.public_header_files = 'LMBUMAdapter/**/*.h'
  # 依赖的第三方库
  s.dependency 'LitemobSDK', '~> 5.0.7'
  # 穿山甲 SDK 作为依赖声明，但不打包进 framework
  # 使用者（主应用）需要自行引入穿山甲 SDK，避免类冲突
  # 注意：这里使用前向声明，实际使用时需要导入穿山甲 SDK 的头文件
  # s.dependency 'Ads-CN', '~> x.x.x'  # 根据实际穿山甲 SDK 版本调整
  s.dependency 'Ads-CN-Beta','~> 7.3.0.4'
  
  # 依赖的系统框架
  s.frameworks = [
    'Foundation',
    'UIKit'
  ]

  # 禁用预编译头，避免引用旧的 LitemizeSDK
  s.prefix_header_file = false
  
  # 配置编译选项：允许非模块化头文件
  s.pod_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'DEFINES_MODULE' => 'YES'
  }
  
  # 注意：Ads-CN-Beta 包含静态链接的二进制文件
  # 提交到 CocoaPods Trunk 时需要使用 --use-libraries 标志
  # 使用者的 Podfile 中建议使用：use_frameworks! :linkage => :dynamic

end

