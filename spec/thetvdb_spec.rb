require 'spec_helper'
require 'ruby-tvscripts/thetvdb'
require 'ruby-tvscripts/config'
require 'yaml'

describe RubyTVScripts::TheTVDB do
  use_vcr_cassette "thetvdb", :record => :new_episodes

  before(:all) do
    config = YAML.load_file(RubyTVScripts::Config.file("tvrenamer.yml")) #change this
    @rage = RubyTVScripts::TheTVDB.new 'F63030FC56E9E594'
  end

  it 'should return a Serie with the searched name' do
    serie = @rage.find_serie 'Eureka', 'fr', :ignore_cache => true
    serie.class.should == RubyTVScripts::Series
    serie.name.should == "Eureka"
  end
  
  it 'should return nil if the tv show does not exist' do
    serie = @rage.find_serie 'InvalidSerie', 'fr', :ignore_cache => true
    serie.should be_nil
  end
  
end