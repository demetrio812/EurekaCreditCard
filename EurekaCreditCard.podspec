#
# Be sure to run `pod lib lint EurekaCreditCard.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "EurekaCreditCard"
  s.version          = "0.1.4"
  s.summary          = "Eureka custom row and cell for credit card data"

  s.description      = <<-DESC
  						Custom Credit Card row for Eureka to quickly collect credit card data in an Eureka form.
                       DESC

  s.homepage         = "https://github.com/demetrio812/EurekaCreditCard"
  s.screenshots     = "https://github.com/demetrio812/EurekaCreditCard/raw/master/demo_styles.png", "https://github.com/demetrio812/EurekaCreditCard/raw/master/demo_selector.png"
  s.license          = 'MIT'
  s.author           = { "Demetrio Filocamo" => "filocamo@demetrio.it" }
  s.source           = { :git => "https://github.com/demetrio812/EurekaCreditCard.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/demetrio812'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'EurekaCreditCard' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Eureka'
  s.dependency 'BKMoneyKit'
end
