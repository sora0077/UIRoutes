Pod::Spec.new do |s|
  s.name         = "UIRoutes"
  s.version      = "0.0.1"
  s.summary      = "UIRoutes is routing library for iOS."

  s.homepage     = "https://github.com/sora0077/UIRoutes"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "t.hayashi" => "t.hayashi0077+bitbucket@gmail.com" }
  s.platform     = :ios, '5.0'
  s.source       = { :git => "https://github.com/sora0077/UIRoutes.git", :tag => "0.0.1" }
  s.source_files  = 'UIRoutes', 'UIRoutes/**/*.{h,m}'
  s.requires_arc = true

end
