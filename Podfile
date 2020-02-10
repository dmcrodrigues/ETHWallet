source 'https://cdn.cocoapods.org/'

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

raise 'Please use bundle exec to run the pod command' unless defined?(Bundler)

platform :ios, '12.0'

target 'ETHWallet' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'web3.swift', '~> 0.3'

  pod 'RxSwift', '~> 5.0'
  pod 'RxCocoa', '~> 5.0'
  pod 'RxFeedback', '~> 3.0'
  pod 'RxDataSources', '~> 4.0'

  target 'ETHWalletTests' do
    inherit! :search_paths
  end

end
