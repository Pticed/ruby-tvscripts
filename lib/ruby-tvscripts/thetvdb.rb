require 'cgi'

require 'ruby-tvscripts/remote_request'

module RubyTVScripts

  class TheTVDB
    
    def initialize api_key
      @api_key = api_key
      @cache = Cache.new Config.xml_cache_dir
    end
    
    def find_serie name, language, options = {}
      do_name_overrides
      name = name.sub(/\(/, "").sub(/\)/, "")
      
      series_xml = @cache.load ["thetvdb", "series_data", language, name]
      if series_xml.nil?
        puts "Fetching #{name} [#{language}] serie from thetvdb"
        series_xml = fetch_serie_xml name, language
        @cache.save ["thetvdb", "series_data", language, name], series_xml
      end
      return nil if series_xml.nil? or series_xml.empty?
      
      series_xmldoc = Nokogiri::XML(series_xml)
      id = (series_xmldoc/"Series/id").text
      name = (series_xmldoc/"Series/SeriesName").text
      serie = Series.new id, name, language, self

    end
    
    def get_episodes serie_id, language
      episodes_xml = @cache.load ["thetvdb", "episode_data", language, serie_id]
      if episodes_xml.nil?
        puts "Fetching #{serie_id} [#{language}] episodes from thetvdb"
        episodes_xml = fetch_episodes_xml serie_id, language
        @cache.save ["thetvdb", "episode_data", language, serie_id], episodes_xml
      end
      episodes_xmldoc = Nokogiri::XML(episodes_xml) unless episodes_xml.nil?
      
      episodes = Hash.new { |hash,key| hash[key] = {} }
      episodes_xmldoc.xpath("Data/Episode").each do |episode|
        episodes[(episode/"SeasonNumber").text][(episode/"EpisodeNumber").text] = (episode/"EpisodeName").text
      end unless episodes_xmldoc.nil?

      episodes
    end
    
    private
    
    def strip_dots(s)
      s.gsub(".","")
    end

    def fetch_serie_xml name, language
      uri = URI.parse("http://thetvdb.com/api/GetSeries.php?seriesname=#{CGI::escape(name)}&language=#{language}")
      res = RemoteRequest.new("get").read(uri)
      doc = Nokogiri::XML(res)
      
      series_xml = nil
      series_element = nil
      
      doc.xpath("Data/Series").each do |element|
        series_element ||= element
        if strip_dots((element/"SeriesName").text.downcase) == strip_dots(name.downcase)
          series_element = element
          break
        end
      end
            
      series_xml = series_element.to_s
    end
    
    def fetch_episodes_xml serie_id, language
      uri = URI.parse("http://thetvdb.com/api/#{api_key}/series/#{serie_id}/all/#{language}.xml")
      res = RemoteRequest.new("get").read(uri)
      
      if res.nil?
        puts "Could not download XML Data for series ID #{serie_id} -- #{uri}"
        return nil
      end
      
      doc = Nokogiri::XML(res)
      doc.xpath("Data").each do |element|
        return element.to_s
      end
    end

    
    def do_name_overrides
      if @name == "CSI" or @name == "CSI: Las Vegas"
        @name = "CSI: Crime Scene Investigation"
      end
    end

  end

end