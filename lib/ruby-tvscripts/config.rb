require 'pathname'

class Config
  
  def self.dir
    if !ENV["HOME"].nil?
      "#{ENV["HOME"]}/.ruby-tvscripts"
    elsif !ENV["APPDATA"].nil?
      "#{ENV["APPDATA"]}/.ruby-tvscripts"
    else
      ""
    end
  end
  
  def self.file filename
    File.join(dir, filename)
  end
  
  def self.file_path filename
    Pathname.new file(filename)
  end

end