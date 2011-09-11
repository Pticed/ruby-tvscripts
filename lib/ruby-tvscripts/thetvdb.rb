require 'cgi'

require 'ruby-tvscripts/remote_request'

module RubyTVScripts

  class TheTVDB
    
    def initialize api_key
      @api_key = api_key
    end
    
    def find_serie name, language
      name = name.sub(/\(/, "").sub(/\)/, "")
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
      series_xml
    end
    
    def get_episodes serie_id, language
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
    
  end

end