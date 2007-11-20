require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Gem::Data, ".new" do
  it "should raise an error without any arguments" do
    lambda { DpkgTools::Package::Gem::Data.new }.should raise_error
  end
  
  it "should require one argument" do
    version = stub('Version', :to_s => '1.0.8')
    stub_spec = stub("stub Gem::Specification", :name => 'gem_name', :version => version, 
                                                :full_name => 'gem_name-1.0.8', :dependencies => :deps,
                                                :summary => 'A gem', :files => :files)
    stub_format = stub('stub Gem::Format', :spec => stub_spec)
    
    DpkgTools::Package::Config.expects(:new).with('gem_name', '1.0.8', :suffix => 'rubygem')
    
    DpkgTools::Package::Gem::Data.new(stub_format)
  end
end

describe DpkgTools::Package::Gem::Data, "instances" do
  before(:each) do
    DpkgTools::Package::Config.root_path = '/a/path/to'
    version = stub('Version', :to_s => '1.0.8')
    @spec = stub("stub Gem::Specification", :name => 'gem_name', :version => version, 
                                            :full_name => 'gem_name-1.0.8', :dependencies => :deps,
                                            :summary => 'A gem', :files => :files)
    @format = stub("stub Gem::Format", :spec => @spec, :file_entries => :file_entries)
    @data = DpkgTools::Package::Gem::Data.new(@format)
  end
  
  it "should provide access to their Gem::Spec" do
    @data.spec.should == @spec
  end
  
  it "should provide access to its name" do
    @data.name.should == 'gem_name'
  end
  
  it "should convert the Gem::Version object to a string" do
    @data.version.should == '1.0.8'
  end
  
  it "should provide access to its full_name" do
    @data.full_name.should == 'gem_name-1.0.8'
  end
  
  it "should provide access to the name, version pair key needed to get a config instance" do
    @data.config_key.should == ['gem_name', '1.0.8']
  end
  
  it "should provide access to the Gem::Format's file_entries attribute" do
    @data.file_entries.should == :file_entries
  end
  
  it "should provide access to the Gem::Specification's files attribute" do
    @data.files.should == :files
  end
  
  it "should provide access to the changelog-derived debian_revision" do
    @data.debian_revision.should == "1"
  end
  
  it "should provide access to the debian architecture name" do
    @data.debian_arch.should == "i386"
  end
  
  it "should provide access to the filename the built .deb will have" do
    @data.deb_filename.should == "gem-name-rubygem_1.0.8-1_i386.deb"
  end
  
  it "should provide access to any dependencies" do
    @data.dependencies.should == :deps
  end
  
  it "should provide access to the summary from the spec" do
    @data.summary.should == @spec.summary
  end
  
  it "should provide access to its associated config instance" do
    @data.config.should be_an_instance_of(DpkgTools::Package::Config)
  end
  
  
  it "should provide access to the path where its package Rakefile should live" do
    @data.rakefile_path.should == '/a/path/to/gem-name-rubygem-1.0.8/Rakefile'
  end
end
