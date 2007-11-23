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
    
    DpkgTools::Package::Gem::Data.new(stub_format, 'gem_byte_string')
  end
end

describe DpkgTools::Package::Gem::Data, "instances" do
  before(:each) do
    DpkgTools::Package::Config.root_path = '/a/path/to'
    version = stub('Version', :to_s => '1.0.8')
    stub_requirement = stub('stub Gem::Requirement', :as_list => [">= 0.0.0"])
    @mock_dep_list = [stub('stub Gem::Dependency', :name => 'whatagem', :version_requirements => stub_requirement)]
    @spec = stub("stub Gem::Specification", :name => 'gem_name', :version => version, 
                                            :full_name => 'gem_name-1.0.8', :dependencies => @mock_dep_list,
                                            :summary => 'A gem', :files => :files)
    @format = stub("stub Gem::Format", :spec => @spec, :file_entries => :file_entries)
    @data = DpkgTools::Package::Gem::Data.new(@format, 'gem_byte_string')
  end
  
  it "should provide access to its gem_byte_string" do
    @data.gem_byte_string.should == 'gem_byte_string'
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
  
  it "should be able to generate a sensible list of deps" do
    @data.send(:base_deps).should == [{:name => "whatagem-rubygem", :requirements => [">= 0.0.0-1"]}]
  end
  
  it "should provide access to any install-time dependencies" do
    @data.dependencies.should == [{:name => "rubygems", :requirements => [">= 0.9.4-1"]},
                                  {:name => "whatagem-rubygem", :requirements => [">= 0.0.0-1"]}]
  end
  
  it "should provide access to any build-time dependencies" do
    @data.build_dependencies.should == [{:name => "rubygems", :requirements => [">= 0.9.4-1"]},
                                        {:name => "rake-rubygem", :requirements => [">= 0.7.0-1"]},
                                        {:name => "dpkg-tools-rubygem", :requirements => [">= #{DpkgTools::VERSION::STRING}-1"]},
                                        {:name => "whatagem-rubygem", :requirements => [">= 0.0.0-1"]}]
  end
  
  it "should provide access to the summary from the spec" do
    @data.summary.should == @spec.summary
  end
  
  it "should provide access to the information DpkgTools::Package::Config needs to generate the package Rakefile's path" do
    @data.rakefile_location.should == [:base_path, 'Rakefile']
  end
end
