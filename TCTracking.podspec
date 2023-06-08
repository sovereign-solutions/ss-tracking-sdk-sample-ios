#
# Be sure to run `pod lib lint TCTracking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TCTracking'
  s.version          = '0.1.0'
  s.summary          = 'techcraft tracking library use for sending gps data to vdms tracking service.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/PhuTruong/TCTracking'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'PhuTruong' => 'truongthienphu@vietbando.vn' }
  s.source           = { :git => 'https://github.com/PhuTruong/TCTracking.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'TCTracking/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TCTracking' => ['TCTracking/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'AlamofireObjectMapper'
  s.dependency 'SwiftyJSON'
  s.dependency 'Alamofire'
  s.dependency 'ObjectMapper'
end
