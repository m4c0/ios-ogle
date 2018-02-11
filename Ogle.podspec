Pod::Spec.new do |spec|
  spec.name = 'Ogle'
  spec.version = '0.0.1'
  spec.summary = 'An old iOS library to wrap the old way of creating games for old iOS devices'
  spec.homepage = 'https://github.com/m4c0/ios-ogle'
  spec.license = { :type => 'GPLv3', :file => 'LICENSE' }
  spec.author = {
    'Eduardo Costa' => 'm4c0@github.com',
  }
  spec.source = { :git => 'https://github.com/m4c0/ios-ogle.git', :tag => "v#{spec.version}" }
  spec.source_files = 'Ogle/*.{h,m}'
  spec.requires_arc = true
  spec.ios.deployment_target = '6.0'
end


