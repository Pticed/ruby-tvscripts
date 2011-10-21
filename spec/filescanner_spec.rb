require 'spec_helper'
require 'ruby-tvscripts/filescanner'

require 'fakefs/safe'
require 'fakefs/file_system'

include FakeFS

describe RubyTVScripts::FileScanner do
  
  before(:all) do
    @scanner = RubyTVScripts::FileScanner.new
    FakeFS.activate!
  end
  
  after(:all) do
    FakeFS.deactivate!
  end

  before(:each) do
    FileSystem.clear
  end
  
  it 'should loop through the files in the given path' do
    FileUtils.touch("/file1.txt")
    FileUtils.touch("/file2.txt")
    
    files = []
    @scanner.scan_files("/") do |file|
      files << file
    end

    files.should == ["/file1.txt", "/file2.txt"]
  end

  it 'should not return directories' do
    FileUtils.mkdir("/root")

    files = []
    @scanner.scan_files("/") do |file|
      files << file
    end

    files.should be_empty
  end

  it 'should loop recursively through the files in the given path' do
    FileUtils.touch("/file1.txt")
    FileUtils.mkdir("/root")
    FileUtils.touch("/root/file2.txt")
    
    files = []
    @scanner.scan_files("/") do |file|
      files << file
    end

    files.should == ["/file1.txt", "/root/file2.txt"]
  end

  it 'should ignore directories when asked' do
    FileUtils.touch("/file1.txt")
    FileUtils.mkdir("/root")
    FileUtils.touch("/root/file2.txt")
    FileUtils.mkdir("/root2")
    FileUtils.touch("/root2/file3.txt")

    @scanner.ignored_folders << "root"

    files = []
    @scanner.scan_files("/") do |file|
      files << file
    end

    files.should == ["/file1.txt", "/root2/file3.txt"]
  end

  it 'should accept only the given file extensions when asked' do
    FileUtils.touch("/file1.txt")
    FileUtils.touch("/file2.xls")

    @scanner.accepted_extensions << "txt"

    files = []
    @scanner.scan_files("/") do |file|
      files << file
    end

    files.should == ["/file1.txt"]
  end
  
  it "should work with relative paths" do
    FakeFS.deactivate!

    files = []
    Dir.chdir fixtures_fs_dir do
      @scanner.scan_files(".") do |file|
        files << file
      end
    end

    files.should == [ File.join(Dir.pwd, fixtures_fs_dir, "file1.txt") ]
    
  end

end