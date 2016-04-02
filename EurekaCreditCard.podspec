Pod::Spec.new do |s|
  s.name = 'EurekaCreditCard'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'Eureka custom row and cell for credit card data'
  s.homepage = 'https://github.com/demetrio812/EurekaCreditCard'
  s.social_media_url = 'http://twitter.com/demetrio812'
  s.authors = { 'Demetrio Filocamo' => 'filocamo@demetrio.it' }
  s.source = { :git => 'https://github.com/demetrio812/EurekaCreditCard.git', :tag => s.version }
  s.ios.deployment_target = '8.0'
  s.ios.frameworks = 'UIKit', 'Foundation'
  s.source_files = 'EurekaCreditCard.swift'
  s.requires_arc = true
end
