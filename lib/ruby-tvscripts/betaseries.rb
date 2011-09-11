require 'cgi'
require 'nokogiri'

require 'ruby-tvscripts/remote_request'
require 'ruby-tvscripts/serie'

module RubyTVScripts

  class BetaSeries
    
    def initialize api_key
      @api_key = api_key
    end
    
    def find_serie name, language, options = {}
      name = name.sub(/\(/, "").sub(/\)/, "")
      
      puts "Fetching #{name} [#{language}] serie from thetvdb"

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
      doc = Nokogiri::XML(res)
      
      show = doc/'root/show'
      id = serie_url
      title = (show/'title').text
      #description = (show/'description').text
      language = 'fr'
      
      serie = Series.new id, title, language, self
      
    end
    
    def get_episodes serie_id, language
      puts "Fetching #{serie_id} [#{language}] episodes from thetvdb"
      
      uri = URI.parse("http://api.betaseries.com/shows/episodes/#{serie_id}.xml?key=#{@api_key}")
      res = RemoteRequest.new("get").read(uri)
      doc = Nokogiri::XML(res)
      
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

  end

end