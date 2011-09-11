require 'fileutils'

module RubyTVScripts
  
  class Cache
    
    def initialize dir
      @dir = dir
	    @cache_time = 24*60*60
    end
    
    def load key
      path = cache_path(key)
      check_expiration(path)
      unless path.file?
        return nil
      end
      puts "Found #{key.inspect} in cache"
	    path.read
    end
    
    def load_xml key
      data = load(key)
      Nokogiri::XML(data) unless data.nil? or data.empty?
    end

    def save key, content
      path = cache_path(key)
      unless path.dirname.directory?
        FileUtils.mkdir_p(path.dirname.to_s)
      end
      path.open("w")  {|file| file.puts content } unless content.nil? or content.empty?
    end

    private
    
    def cache_path key
      Pathname.new(File.join(@dir,key)+".xml")
    end
    
    def check_expiration(path)
      path.delete if path.file? && cache_expired(path)
    end
    
    def cache_expired(filepath)
      Time.now - filepath.mtime > @cache_time
    end
    
  end
  
end