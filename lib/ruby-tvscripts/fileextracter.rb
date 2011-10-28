module RubyTVScripts

  class FileExtracter
    REGEXPS = [ /([0-9]+)x([0-9]+)(x(\d+))?/i, /s([0-9]+)e([0-9]+)(e(\d+))?/i]
    
    def analyse file
      infos = nil
      
      REGEXPS.each do |pattern|
        if file.match(pattern)
          infos = { :season => $1.to_i, :episode => $2.to_i }
          infos[:episode2] = $4.to_i if $4
          break
        end
      end
      
      unless infos
        if file.match(/(\d+)/)
          season_and_episode = $1.to_i
          if season_and_episode > 99 && season_and_episode < 1900
            infos = { :season => season_and_episode / 100, :episode => season_and_episode % 100 }
          end
        end
      end
      
      infos
    end
    
  end

end