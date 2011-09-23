require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

desc "Run all specs with RCov"
RSpec::Core::RakeTask.new('spec:rcov') do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,gems/*']
end