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

      series_xml = cache.load ["series_data", @language, @name]
      if series_xml.nil?
        puts "Fetching #{@name} [#{@language}] serie from thetvdb"
        series_xml = get_series_xml()
        cache.save ["series_data", @language, @name], series_xml
      end
      @series_xmldoc = Nokogiri::XML(series_xml)
      
      return nil if series_xml.nil? or series_xml.empty?
      
      @name = (@series_xmldoc/"Series/SeriesName").text
      
      episodes_xml = cache.load ["episode_data", @language, @name]
      if episodes_xml.nil?
        puts "Fetching #{@name} [#{@language}] episodes from thetvdb"
        episodes_xml = get_episodes_xml(id)
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

    def get_episodes_xml(series_id)
      uri = URI.parse("http://thetvdb.com/api/#{API_KEY}/series/#{series_id}/all/#{@language}.xml")
      res = RemoteRequest.new("get").read(uri)
      
      if res.nil?
        puts "Could not download XML Data for series ID #{series_id} -- #{url}"
        return nil
      end
      
      doc = Nokogiri::XML(res)
      doc.xpath("Data").each do |element|
        return element.to_s
      end
    end
    
    def get_series_xml
      name = @name.sub(/\(/, "").sub(/\)/, "")
      uri = URI.parse("http://thetvdb.com/api/GetSeries.php?seriesname=#{CGI::escape(name)}&language=#{@language}")
      
      res = RemoteRequest.new("get").read(uri)
      
      doc = Nokogiri::XML(res)
      
      series_xml = nil
      series_element = nil
      
      doc.xpath("Data/Series").each do |element|
        series_element ||= element
        if strip_dots((element/"SeriesName").text.downcase) == strip_dots(@name.downcase)
          series_element = element
          break
        end
      end
      series_xml = series_element.to_s
      series_xml
    end
    
    def get_episode(filename, season, episode_number, refresh)
      Episode.new(self, filename, season, episode_number, refresh)
    end
    
    private

  end
end