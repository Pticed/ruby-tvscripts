require 'rubygems'
require 'rspec'

require 'vcr'
require 'fakeweb'

VCR.config do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.stub_with :webmock # or :fakeweb
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
  c.filter_run_excluding :disabled => true
end