module RubyTVScripts

  class PathExtracter
    
    def analyse filepath
      path = Pathname.new filepath
      infos = {}
      
      if path.basename.to_s.match(/Season|Saison/)
        season_path = path
        show_path = season_path.parent

        season = season_path.basename.to_s
        infos[:season] = season.match(/(\d+)/)[0].to_i
        infos[:lang] = season.match(/Saison/i) ? 'fr': 'en'
      else
        show_path = path
      end

      infos[:show] = show_path.basename.to_s

      infos
    end
  end

end