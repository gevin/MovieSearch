# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MovieListDemo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MovieListDemo
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'RxDataSources', '~> 3.0'
  
  pod 'RealmSwift'
  
  pod 'Moya/RxSwift', '~> 11.0'
  pod 'SDWebImage'
  pod 'SVProgressHUD'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['RxSwift', 'RxCocoa', 'RxDataSources', 'RealmSwift', 'Moya/RxSwift'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
end
