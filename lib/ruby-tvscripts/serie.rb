require 'nokogiri'
require 'ruby-tvscripts/config'
require 'ruby-tvscripts/episode'
require 'ruby-tvscripts/cache'

module RubyTVScripts

  class Series
  
    attr_reader :id, :name, :language
  
    def initialize(id, name, language, fetcher)
      @id = id
      @name = name
      @language = language
      @fetcher = fetcher      
    end
    
    def episodes
      @episodes = @fetcher.get_episodes @id, @language if @episodes.nil?
      @episodes
    end
        
    def get_episode(filename, season, episode_number, refresh)
      Episode.new(self, filename, season, episode_number, refresh)
    end

  end
end