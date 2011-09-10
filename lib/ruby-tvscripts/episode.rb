module RubyTVScripts

  class Episode
    attr_reader :series, :season, :filename, :episode_number, :raw_name

    def initialize(series, filename, season, episode_number, refresh)
      @filename = filename
      @series = series
      @season = season
      @episode_number = episode_number
      @raw_name = series.episodes[season][episode_number]
    end
  
    def name()
      get_name_and_part[0]
    end
  
    def part()
      get_name_and_part[1]
    end
  
    def get_name_and_part
      name = raw_name
      if name =~ /^(.*) \(([0-9]*)\)$/
        name = $1
        part = $2
      else
        part = nil
      end
      return [name, part]
    end

  end

end