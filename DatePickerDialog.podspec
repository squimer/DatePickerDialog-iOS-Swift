Pod::Spec.new do |s|
  s.name         = "DatePickerDialog"
  s.version      = "1.1.7"
  s.summary      = "Date picker dialog for iOS"
  s.homepage     = "https://github.com/squimer/DatePickerDialog-iOS-Swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Lucas Farah" => "lucas.farah@me.com" }
  s.social_media_url   = "https://twitter.com/7farah7"
  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/squimer/DatePickerDialog-iOS-Swift.git", :tag => s.version }
  s.source_files  = "Sources/*.swift"
  s.requires_arc = true
end

