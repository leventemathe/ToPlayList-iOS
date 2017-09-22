platform :ios, '10.3'

use_frameworks!

def my_pods
  pod 'Alamofire', '~> 4.5.1'
  pod 'Kingfisher', '~> 4.0.1'
  pod 'Firebase/Core', '~> 4.2.0'
  pod 'Firebase/Auth', '~> 4.2.0'
  pod 'Firebase/Database', '~> 4.2.0'
  pod 'Firebase/AdMob', '~> 4.2.0'
  pod 'NVActivityIndicatorView', '~> 4.0.0'
  pod 'ImageViewer', :git => 'https://github.com/leviouss/ImageViewer'
end

target 'ToPlayList' do
  my_pods
end

target 'ToPlayListDev' do
  my_pods

  target 'ToPlayListUnitTests' do
    inherit! :search_paths
  end
end