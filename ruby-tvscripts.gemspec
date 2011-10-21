Gem::Specification.new do |spec|
  spec.name = 'ruby-tvscripts'
  spec.version ='0.0.3'

  spec.authors = [ 'Brian Stolz', 'Cédric Finance' ]
  spec.email = [ 'brian@tecnobrat.com', 'pticedric@gmail.com']
  spec.homepage = "http://www.tecnobrat.com/"
  
  spec.summary = "A collection of scripts to manage and organize your TV show library"
  
  spec.files = ["lib/ruby-tvscripts/net-http-compression.rb",
                "lib/ruby-tvscripts/remote_request.rb",
                "lib/ruby-tvscripts/serie.rb",
                "lib/ruby-tvscripts/episode.rb",
                "lib/ruby-tvscripts/config.rb",
                "lib/ruby-tvscripts/cache.rb",
                "lib/ruby-tvscripts/filescanner.rb",
                "lib/ruby-tvscripts/thetvdb.rb",
                "lib/ruby-tvscripts/betaseries.rb",
                "lib/ruby-tvscripts/tvrage.rb",
               ]
  spec.executables = ["delete-watched", "download-status", "trakt-library-import", "tvmover", "tvrenamer" ]
  
end