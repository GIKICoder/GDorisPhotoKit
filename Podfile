# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def mainApp_pods
   pod 'YYText'
   pod 'YYImage'
   pod 'YYImage/WebP'
   pod 'SDWebImage', '~> 5.0'
   pod 'SDWebImageWebPCoder', :git => 'https://github.com/SDWebImage/SDWebImageWebPCoder.git', :branch => 'master'
   pod 'SDWebImageYYPlugin'
   pod 'Masonry'
   pod 'FLAnimatedImage'

end

target 'GDorisPhotoKit' do
  mainApp_pods
 
  target 'GDorisPhotoKitTests' do
    # Pods for testing
  end
  target 'Example-iOS' do
    mainApp_pods
  end
end
