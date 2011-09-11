require 'cgi'
require 'nokogiri'

require 'ruby-tvscripts/remote_request'
require 'ruby-tvscripts/serie'

module RubyTVScripts

  class TVRage
    
    def initialize
      @cache = Cache.new Config.xml_cache_dir
    end
    
    def find_serie name, language, options = {}
      name = name.sub(/\(/, "").sub(/\)/, "")
      
      doc = @cache.load_xml ["tvrage", "series_data", name]
      if doc.nil?
        puts "Fetching #{name} [#{language}] serie from TVRage"
        doc = fetch_serie_xml name
        @cache.save ["tvrage", "series_data", name], doc.to_s
      end
      return nil if doc.nil?
      
      id = (doc/'showid').text
      title = (doc/'name').text
      language = 'en'
      
      serie = Series.new id, title, language, self
      
    end
    
    def get_episodes serie_id, language    
      doc = @cache.load_xml ["tvrage", "episode_data", serie_id]
      if doc.nil?
        puts "Fetching #{serie_id} [#{language}] episodes from TVRage"
        doc = fetch_episodes_xml serie_id
        @cache.save ["tvrage", "episode_data", serie_id], doc.to_s
      end
      return nil if doc.nil?
      
      episodes = Hash.new { |hash,key| hash[key] = {} }
      (doc/'Show/Episodelist/Season').each do |season|
        season_nb = season.attribute('no').text
        (season/'episode').each do |episode|
          episode_nb = (episode/'seasonnum').text.to_i.to_s
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
      uri = URI.parse("http://services.tvrage.com/feeds/search.php?show=#{CGI::escape(name)}")
      res = RemoteRequest.new("get").read(uri)
      doc = Nokogiri::XML(res)

      serie_element = nil

      doc.xpath("Results/show").each do |element|
        if strip_dots((element/"name").text.downcase) == strip_dots(name.downcase)
          serie_element = element
          break
        end
      end

      serie_element
    end

    def fetch_episodes_xml serie_id
      uri = URI.parse("http://services.tvrage.com/feeds/episode_list.php?sid=#{serie_id}")
      res = RemoteRequest.new("get").read(uri)
      doc = Nokogiri::XML(res)      
    end

  end

end