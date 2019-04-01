
Pod::Spec.new do |s|

  s.name         = "EventNotification"
  s.version      = "0.9"
  s.summary      = "Typed notification events"
  s.description  = "Send arbitrary data between parts of an application that are not directly connected."


  s.homepage     = "https://github.com/arkdan/EventNotification"
  s.license      = "MIT (example)"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = "ark dan"

  s.platform     = :ios
  s.platform     = :ios, "8.0"

  s.swift_version = "4.0"

  s.source       = { :git => "https://github.com/arkdan/EventNotification.git", :tag => s.version }
  s.source_files  = "EventNotification/*.{h,m,swift}"

end
