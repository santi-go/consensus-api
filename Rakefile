require 'rspec/core/rake_task'

task :default => :start

task :start do
  sh "rerun --background -- rackup --port 4567 -o 0.0.0.0"
end

task :test do
  sh 'rspec'
end

task :tag, [:tag] do |t, arg|
  sh "rspec --tag #{arg.tag}"
end

desc 'Run labeled tests'
RSpec::Core::RakeTask.new do |test, args|
  test.pattern = Dir['spec/**/*_spec.rb']
  test.rspec_opts = args.extras.map { |tag| "--tag #{tag}" }
end
