require 'spec_helper'
require 'ruby-tvscripts/betaseries'
require 'ruby-tvscripts/config'
require 'yaml'

describe RubyTVScripts::BetaSeries do
  use_vcr_cassette "betaseries", :record => :new_episodes

  before(:all) do
    config = YAML.load_file(RubyTVScripts::Config.file("tvrenamer.yml")) #change this
    @rage = RubyTVScripts::BetaSeries.new config["betaseries_key"]
  end

  it 'should return a Serie with the searched name' do
    serie = @rage.find_serie 'Eureka', 'fr', :ignore_cache => true
    serie.class.should == RubyTVScripts::Series
    serie.name.should == "Eureka"
  end
  
  it 'should return nil if the tv show does not exist' do
    serie = @rage.find_serie 'Invalid', 'fr', :ignore_cache => true
    serie.should be_nil
  end
  
end