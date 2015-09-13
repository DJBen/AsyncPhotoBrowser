Pod::Spec.new do |s|

  s.name         = "AsyncPhotoBrowser"
  s.version      = "0.1.0"
  s.summary      = "High performance photo browser designed for web images built with FastImageCache. Contains a grid view; can zoom in/out specific image and scroll across images."

  s.homepage     = "https://github.com/DJBen/AsyncPhotoBrower"

  s.license      = "MIT"

  s.author       = { "Sihao Lu" => "lsh32768@gmail.com" }
  
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/DJBen/AsyncPhotoBrower", :tag => "0.1.0" }

  s.source_files  = "FNAsyncGallery/Classes/*.{h,m,swift}"

  s.requires_arc = true

  s.dependency 'FastImageCache', '~> 1.3'
  s.dependency 'Alamofire'
  s.dependency 'Cartography', '0.6.0-beta1'

end
