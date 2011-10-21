module RubyTVScripts

  class FileScanner

    attr_accessor :ignored_folders, :accepted_extensions

    def initialize
      @ignored_folders = []
      @accepted_extensions = []
    end

    def scan_files start_path
      paths = [ File.expand_path(start_path) ]
      
      while path = paths.shift
        if File.directory?(path)
          next if folder_ignored?(path)
          Dir.entries(path).reverse_each do |entry|
            next if entry == "." or entry == ".."
            paths.unshift File.join(path, entry)
          end
        else
          next unless file_accepted?(path)
          yield path
        end
      end
    end

    private

    def folder_ignored?(path)
      @ignored_folders.include? File.basename(path)
    end

    def file_accepted?(path)
      @accepted_extensions.empty? or @accepted_extensions.any? { |extension| path.end_with?(extension) }
    end


  end

end