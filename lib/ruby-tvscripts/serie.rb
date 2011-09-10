require 'nokogiri'
require 'ruby-tvscripts/config'
require 'ruby-tvscripts/episode'

module RubyTVScripts

  class Series
  
    attr_reader :name, :episodes
  
    def initialize(name, refresh, language)
      @name = name
      do_name_overrides
      @language = language
      @series_xml_path = Pathname.new("#{Config.dir}/xml_cache/series_data/#{@name}.#{@language}.xml")
      @episodes_xml_path = Pathname.new("#{Config.dir}/xml_cache/episode_data/#{@name}.#{@language}.xml")
      @episodes = Hash.new { |hash,key| hash[key] = {} }
      @series_xml_path.delete if @series_xml_path.file? && cache_expired(@series_xml_path)
      @episodes_xml_path.delete if @episodes_xml_path.file? && cache_expired(@episodes_xml_path)
      if not @series_xml_path.file?
        puts "Fetching #{@name} [#{@language}] serie from thetvdb"
        series_xml = get_series_xml()
        #ensure we have a xml_cache dir
        unless @series_xml_path.dirname.directory?
          FileUtils.mkdir_p(@series_xml_path.dirname.to_s)
        end
        @series_xml_path.open("w")  {|file| file.puts series_xml} unless series_xml.nil? or series_xml.empty?
      else
        puts "Loading #{@name} [#{@language}] serie from cache"
        series_xml = @series_xml_path.read
      end
      @series_xmldoc = Nokogiri::XML(series_xml)
      
      return nil if series_xml.nil? or series_xml.empty?
      
      @name = (@series_xmldoc/"Series/SeriesName").text
      
      if not @episodes_xml_path.file?
        puts "Fetching #{@name} [#{@language}] episodes from thetvdb"
        episodes_xml = get_episodes_xml(id)
        
        #ensure we have a xml_cache dir
        unless @episodes_xml_path.dirname.directory?
          FileUtils.mkdir_p(@episodes_xml_path.dirname.to_s)
        end
        @episodes_xml_path.open("w")  {|file| file.puts episodes_xml}
      else
        puts "Loading #{@name} [#{@language}] episodes from cache"
        episodes_xml = @episodes_xml_path.read
      end
      @episodes_xmldoc = Nokogiri::XML(episodes_xml) unless episodes_xml.nil?
      
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
    
    def cache_expired(filepath)
      Time.now - File.mtime(filepath) > @@series_cache
    end
  end
end