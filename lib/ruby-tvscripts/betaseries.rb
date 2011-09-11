require 'cgi'
require 'nokogiri'

require 'ruby-tvscripts/remote_request'
require 'ruby-tvscripts/serie'

module RubyTVScripts

  class BetaSeries
    
    def initialize api_key
      @api_key = api_key
      @cache = Cache.new Config.xml_cache_dir
    end
    
    def find_serie name, language, options = {}
      name = name.sub(/\(/, "").sub(/\)/, "")
      
      serie_xml = @cache.load ["betaseries", "series_data", name]
      if serie_xml.nil?
        puts "Fetching #{name} [#{language}] serie from BetaSeries"
        serie_xml = fetch_serie_xml name
        @cache.save ["betaseries", "series_data", name], serie_xml
      end
      return nil if serie_xml.nil? or serie_xml.empty?
      
      doc = Nokogiri::XML(serie_xml)
      
      show = doc/'root/show'
      id = (show/'url').text
      title = (show/'title').text
      #description = (show/'description').text
      language = 'fr'
      
      serie = Series.new id, title, language, self
      
    end
    
    def get_episodes serie_id, language
      episodes_xml = @cache.load ["betaseries", "episode_data", serie_id]
      if episodes_xml.nil?
        puts "Fetching #{serie_id} [#{language}] episodes from BetaSeries"
        uri = URI.parse("http://api.betaseries.com/shows/episodes/#{serie_id}.xml?key=#{@api_key}")
        episodes_xml = RemoteRequest.new("get").read(uri)
        @cache.save ["betaseries", "episode_data", serie_id], episodes_xml
      end
      doc = Nokogiri::XML(episodes_xml)
      
      episodes = Hash.new { |hash,key| hash[key] = {} }
      (doc/'root/seasons/season').each do |season|
        season_nb = (season/'number')[0].text
        (season/'episodes/episode').each do |episode|
          episode_nb = (episode/'episode').text
          episodes[season_nb][episode_nb] = (episode/'title').text
        end
      end
      
      episodes
    end
    
    private
    
    def strip_dots(s)
      s.gsub(".","")
    end

    def fetch_serie_xml name
      uri = URI.parse("http://api.betaseries.com/shows/search.xml?title=#{CGI::escape(name)}&key=#{@api_key}")
      res = RemoteRequest.new("get").read(uri)
      doc = Nokogiri::XML(res)

      series_xml = nil
      serie_url = nil

      doc.xpath("root/shows/show").each do |element|
        if strip_dots((element/"title").text.downcase) == strip_dots(name.downcase)
          serie_url = (element/"url").text
          break
        end
      end

      uri = URI.parse("http://api.betaseries.com/shows/display/#{serie_url}.xml?key=#{@api_key}")
      res = RemoteRequest.new("get").read(uri)

    end
  end

end