require 'nokogiri'
require 'ruby-tvscripts/config'
require 'ruby-tvscripts/episode'
require 'ruby-tvscripts/cache'

module RubyTVScripts

  class Series
  
    attr_reader :name, :episodes
  
    def initialize(name, refresh, language)
      @name = name
      do_name_overrides
      @language = language
      cache = Cache.new Config.xml_cache_dir

      fetcher = TheTVDB.new 'F63030FC56E9E594'

      series_xml = cache.load ["series_data", @language, @name]
      if series_xml.nil?
        puts "Fetching #{@name} [#{@language}] serie from thetvdb"
        series_xml = fetcher.find_serie @name, @language
        cache.save ["series_data", @language, @name], series_xml
      end
      @series_xmldoc = Nokogiri::XML(series_xml)
      
      return nil if series_xml.nil? or series_xml.empty?
      
      @name = (@series_xmldoc/"Series/SeriesName").text
      
      episodes_xml = cache.load ["episode_data", @language, @name]
      if episodes_xml.nil?
        puts "Fetching #{@name} [#{@language}] episodes from thetvdb"
        episodes_xml = fetcher.get_episodes id, @language
        cache.save ["episode_data", @language, @name], episodes_xml
      end
      @episodes_xmldoc = Nokogiri::XML(episodes_xml) unless episodes_xml.nil?
      
      @episodes = Hash.new { |hash,key| hash[key] = {} }
      @episodes_xmldoc.xpath("Data/Episode").each do |episode|
        @episodes[(episode/"SeasonNumber").text][(episode/"EpisodeNumber").text] = (episode/"EpisodeName").text
      end unless @episodes_xmldoc.nil?
      
    end
    
    def id()
      (@series_xmldoc/"Series/id").text
    end
    
    def do_name_overrides
      if @name == "CSI" or @name == "CSI: Las Vegas"
        @name = "CSI: Crime Scene Investigation"
      end
    end
    
    def strip_dots(s)
      s.gsub(".","")
    end

    def get_episode(filename, season, episode_number, refresh)
      Episode.new(self, filename, season, episode_number, refresh)
    end
    
    private

  end
end