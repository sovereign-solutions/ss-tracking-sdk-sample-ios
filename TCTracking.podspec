#
# Be sure to run `pod lib lint TCTracking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TCTracking'
  s.version          = '0.2.0'
  s.summary          = 'techcraft tracking library'
  s.swift_version    = '4.0'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'techcraft tracking library use for sending gps data to vdms tracking service.'

  s.homepage         = 'https://github.com/phutttc/TCTracking'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'PhuTruong' => 'phu.truong@techcraft.vn' }
  s.source           = { :git => 'https://github.com/phutttc/TCTracking.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'TCTracking/Classes/**/*'
  
  # s.resource_bundles = {
  #   'TCTracking' => ['TCTracking/Assets/*.png']
  # }

end
