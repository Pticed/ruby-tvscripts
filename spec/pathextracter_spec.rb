require 'ruby-tvscripts/pathextracter'

describe RubyTVScripts::PathExtracter do
  
  before(:all) do
    @extracter = RubyTVScripts::PathExtracter.new
  end

  describe 'Show/Season' do

    it 'should find the show name' do
      infos = @extracter.analyse 'Eureka/Saison 1'
      infos[:show].should == "Eureka"

      infos = @extracter.analyse 'Bones/Saison 1'
      infos[:show].should == "Bones"
    end

    it 'should find the show season number' do
      infos = @extracter.analyse 'Eureka/Saison 1'
      infos[:season].should == 1

      infos = @extracter.analyse 'Eureka/Saison 2'
      infos[:season].should == 2
    end

    it 'should find the language' do
      infos = @extracter.analyse 'Eureka/Saison 1'
      infos[:lang].should == 'fr'

      infos = @extracter.analyse 'Eureka/Season 1'
      infos[:lang].should == 'en'
    end

  end

  describe 'Show' do

    it 'should find the show name' do
      infos = @extracter.analyse 'Eureka'
      infos[:show].should == "Eureka"

      infos = @extracter.analyse 'Bones'
      infos[:show].should == "Bones"
    end

  end

end