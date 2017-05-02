Pod::Spec.new do |s|
  s.name         = "FXSqlite"
  s.version      = "1.0.0"
  s.summary      = "路由框架"

  s.homepage     = "https://github.com/zqw87699/FXSqlite"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = {"zhangdazong" => "929013100@qq.com"}

  s.source       = { :git => "https://github.com/zqw87699/FXSqlite.git", :tag => "#{s.version}"}

  s.platform     = :ios, "7.0"

  s.frameworks = "Foundation", "UIKit", "sqlite3"

  s.module_name = 'FXSqlite' 

  s.requires_arc = true

  s.source_files = 'Classes/*'
  s.public_header_files = 'Classes/*.h'

  s.dependency "FXLog"
  s.dependency "FXCommon/Core" 
  s.dependency "FXCommon/Utiles"
  s.dependency 'FXJson'

end
