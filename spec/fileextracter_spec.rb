require 'spec_helper'

require 'ruby-tvscripts/fileextracter'

describe RubyTVScripts::FileExtracter do

  before(:all) do
    @extracter = RubyTVScripts::FileExtracter.new
  end
  
  describe "format 1x01x02" do

    it 'should find infos' do
      infos = @extracter.analyse "Bones 1x01.avi"
      infos[:season].should == 1
      infos[:episode].should == 1

      infos = @extracter.analyse "Bones 4x10.avi"
      infos[:season].should == 4
      infos[:episode].should == 10
    end

    it 'should be case insensitive' do
      infos = @extracter.analyse "Bones 4X10.avi"
      infos[:season].should == 4
      infos[:episode].should == 10
    end

    it 'should find a second episode' do
      infos = @extracter.analyse "Bones 4X10x11.avi"
      infos[:season].should == 4
      infos[:episode].should == 10
      infos[:episode2].should == 11
    end

  end

  describe "format S01E01E02" do

    it 'should find infos' do
      infos = @extracter.analyse "Bones s01e01.avi"
      infos[:season].should == 1
      infos[:episode].should == 1

      infos = @extracter.analyse "Bones s04e10.avi"
      infos[:season].should == 4
      infos[:episode].should == 10
    end

    it 'should be case insensitive' do
      infos = @extracter.analyse "Bones S04E10.avi"
      infos[:season].should == 4
      infos[:episode].should == 10
    end

    it 'should find a second episode' do
      infos = @extracter.analyse "Bones S04E10E11.avi"
      infos[:season].should == 4
      infos[:episode].should == 10
      infos[:episode2].should == 11
    end

  end

  describe "format 101" do

    it 'should find infos' do
      infos = @extracter.analyse "Bones 101.avi"
      infos[:season].should == 1
      infos[:episode].should == 1

      infos = @extracter.analyse "Bones 410.avi"
      infos[:season].should == 4
      infos[:episode].should == 10

      infos = @extracter.analyse "Bones 1010.avi"
      infos[:season].should == 10
      infos[:episode].should == 10
    end

    it 'should not match years' do
      infos = @extracter.analyse "Bones 2005.avi"
      infos.should be_nil

      infos = @extracter.analyse "Bones 1900.avi"
      infos.should be_nil
    end

    it 'should not match number less than 99' do
      infos = @extracter.analyse "Bones 99.avi"
      infos.should be_nil
    end

  end

end