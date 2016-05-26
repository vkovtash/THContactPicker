Pod::Spec.new do |s|
  s.name         = 'ZIMTHContactPicker'
  s.version      = '0.3.4'
  s.summary      = "Contact picker view controller"
  s.homepage     = 'https://github.com/vkovtash/THContactPicker'

  s.license      = 'MIT'
  s.author       = { 'Tristan Himmelman' => '' }
  s.source       = { :git => 'https://github.com/vkovtash/THContactPicker.git', :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Classes/**/*.{h,m}'
  
  s.framework    = 'QuartzCore'
  s.framework    = 'CoreGraphics'  
end
