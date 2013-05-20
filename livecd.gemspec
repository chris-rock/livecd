spec = Gem::Specification.new do |s|
  s.name = 'livecd'
  s.version = '0.2'
  s.platform = Gem::Platform::RUBY
  s.summary = "run livecds easily"
  s.description = s.summary
  s.author = "Dominik Richter"
  s.email = "dominik.richter@googlemail.com"

  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
