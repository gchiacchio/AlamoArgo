#
# Be sure to run `pod lib lint AlamoArgo.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AlamoArgo"
  s.version          = "0.2.3"
  s.summary          = "REST object mapping with Alamofire and Argo. The easy way."
  s.description      = <<-DESC
                       Alamofire extensions to handle responses with Argo's `Decodable` objects.
                       DESC
  s.homepage         = "https://github.com/gchiacchio/AlamoArgo"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Guillermo Chiacchio" => "guillermo.chiacchio@gmail.com" }
  s.source           = { :git => "https://github.com/gchiacchio/AlamoArgo.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Gvi113'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.requires_arc = true

  s.source_files = '*.swift'

  s.dependency 'Alamofire', '~> 1.2'
  s.dependency 'Argo', '~> 1.0'
end
