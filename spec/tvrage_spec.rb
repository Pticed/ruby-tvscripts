require 'spec_helper'
require 'ruby-tvscripts/tvrage'


describe RubyTVScripts::TVRage do
  use_vcr_cassette "tvrage", :record => :new_episodes

  before(:all) do
    @rage = RubyTVScripts::TVRage.new    
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

  it 'should fetch the episodes too' do
    serie = @rage.find_serie 'Eureka', 'fr', :ignore_cache => true
    serie.episodes(:ignore_cache => true).should_not be_empty
  end

end