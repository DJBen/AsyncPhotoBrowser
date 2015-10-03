Pod::Spec.new do |s|

  s.name         = "AsyncPhotoBrowser"
  s.version      = "0.2.1"
  s.summary      = "High performance photo browser designed for web images built with FastImageCache. Contains a grid view; can zoom in/out specific image and scroll across images."

  s.homepage     = "https://github.com/DJBen/AsyncPhotoBrowser"

  s.license      = "MIT"

  s.author       = { "Sihao Lu" => "lsh32768@gmail.com" }
  
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/DJBen/AsyncPhotoBrowser.git", :tag => "#{s.version}" }

  s.source_files  = "AsyncPhotoBrowser/Classes/*.{h,m,swift}"

  s.requires_arc = true

  s.dependency 'FastImageCache', '~> 1.3'
  s.dependency 'Alamofire'
  s.dependency 'Cartography'

end
