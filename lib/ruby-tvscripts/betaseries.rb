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
      
      doc = @cache.load_xml ["betaseries", "series_data", name]
      if doc.nil?
        puts "Fetching #{name} [#{language}] serie from BetaSeries"
        docc = fetch_serie_xml name
        @cache.save ["betaseries", "series_data", name], doc.to_s
      end
      return nil if doc.nil?

      show = doc/'root/show'
      id = (show/'url').text
      title = (show/'title').text
      #description = (show/'description').text
      language = 'fr'
      
      serie = Series.new id, title, language, self
      
    end
    
    def get_episodes serie_id, language
      doc = @cache.load_xml ["betaseries", "episode_data", serie_id]
      if doc.nil?
        puts "Fetching #{serie_id} [#{language}] episodes from BetaSeries"
        uri = URI.parse("http://api.betaseries.com/shows/episodes/#{serie_id}.xml?key=#{@api_key}")
        doc = RemoteRequest.new("get").read(uri)
        @cache.save ["betaseries", "episode_data", serie_id], doc.to_s
      end
      
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
      Nokogiri::XML(res)
    end
  end

end