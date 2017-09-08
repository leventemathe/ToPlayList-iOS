platform :ios, '9.0'

use_frameworks!

def my_pods
  pod 'Alamofire', '~> 4.4.0'
  pod 'Kingfisher', '~> 3.9.1'
  pod 'Firebase/Core', '~> 4.0.4'
  pod 'Firebase/Auth', '~> 4.0.4'
  pod 'Firebase/Database', '~> 4.0.4'
  pod 'Firebase/AdMob', '~> 4.0.3'
  pod 'NVActivityIndicatorView', '~> 3.6.1'
  pod 'ImageViewer', '~> 4.1.0'
  pod 'SwiftyStoreKit', '~> 0.10.7'
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