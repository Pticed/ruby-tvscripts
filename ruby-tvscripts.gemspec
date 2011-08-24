Gem::Specification.new do |spec|
  spec.name = 'ruby-tvscripts'
  spec.version ='0.0.1'

  spec.authors = [ 'Brian Stolz', 'Cédric Finance' ]
  spec.email = [ 'brian@tecnobrat.com', 'pticedric@gmail.com']
  spec.homepage = "http://www.tecnobrat.com/"
  
  spec.summary = "A collection of scripts to manage and organize your TV show library"
  
  spec.files = ["lib/ruby-tvscripts/net-http-compression.rb"]
  spec.executables = ["delete-watched", "download-status", "trakt-library-import", "tvmover", "tvrenamer" ]
  
end