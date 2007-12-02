require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Gem::Data do
  it "should report its resources_dirname correctly" do
    DpkgTools::Package::Gem::Data.resources_dirname.should == 'gem'
  end
end

describe DpkgTools::Package::Gem::Data, ".native_extension_deps (managing c-library deps for gems which compile native extensions)" do
  it "should be able to retrieve a list of deps given a gem name and version number" do
    DpkgTools::Package::Gem::Data.stubs(:native_extensions_deps_map).returns({'name' => {'1.0.8' => [{:name => 'package-devel'}]}})
    DpkgTools::Package::Gem::Data.native_extension_deps('name', '1.0.8').should == [{:name => 'package-devel'}]
  end
  
  it "should be able to retrieve a list of deps given a gem name and version number even if no specific deps for that version exist" do
    DpkgTools::Package::Gem::Data.stubs(:native_extensions_deps_map).returns({'name' => {'all' => [{:name => 'package-devel'}]}})
    DpkgTools::Package::Gem::Data.native_extension_deps('name', '1.0.8').should == [{:name => 'package-devel'}]
  end
end

describe DpkgTools::Package::Gem::Data, ".native_extensions_deps_map (managing c-library deps for gems which compile native extensions)" do
  it "should load its map of gems with native extensions -> deps from a YAML file" do
    DpkgTools::Package::Gem::Data.stubs(:resources_path).returns('/a/path/to')
    YAML.expects(:load_file).with('/a/path/to/gems_to_deps.yml').returns(:hash)
    DpkgTools::Package::Gem::Data.expects(:process_extensions_map).with(:hash).returns(:hash)
    DpkgTools::Package::Gem::Data.native_extensions_deps_map.should == :hash
  end
  
  it "should cache the result of process_extensions_map" do
    DpkgTools::Package::Gem::Data.send(:remove_instance_variable, :@native_extensions_deps_map)
    YAML.stubs(:load_file).returns(:hash)
    DpkgTools::Package::Gem::Data.expects(:process_extensions_map).with(:hash).returns(:hash)
    DpkgTools::Package::Gem::Data.native_extensions_deps_map.should == :hash
    DpkgTools::Package::Gem::Data.native_extensions_deps_map.should == :hash
  end
end

describe DpkgTools::Package::Gem::Data, ".process_extensions_map (managing c-library deps for gems which compile native extensions)" do
  it "should be able to process a gem entry with a single specific version with a single dep" do
    input_hash =  {'name' => {'1.0.8' => 'dep'}}
    DpkgTools::Package::Gem::Data.process_extensions_map(input_hash).should == {'name' => {'1.0.8' => [{:name => 'dep'}]}}
  end
  
  it "should be able to process a gem entry with a single specific version with multiple deps" do
    input_hash =  {'name' => {'1.0.8' => ['dep1', 'dep2']}}
    DpkgTools::Package::Gem::Data.process_extensions_map(input_hash).should == {'name' => {'1.0.8' => [{:name => 'dep1'}, {:name => 'dep2'}]}}
  end
  
  it "should be able to process a gem entry with a single dep" do
    input_hash =  {'name' => 'dep'}
    DpkgTools::Package::Gem::Data.process_extensions_map(input_hash).should == {'name' => {'all' => [{:name => 'dep'}]}}
  end
  
  it "should be able to process a gem entry with multiple deps" do
    input_hash =  {'name' => ['dep1', 'dep2']}
    DpkgTools::Package::Gem::Data.process_extensions_map(input_hash).should == {'name' => {'all' => [{:name => 'dep1'}, {:name => 'dep2'}]}}
  end
  
  it "should be able to process a gem entry with a single dep" do
    input_hash =  {'name' => 'dep'}
    DpkgTools::Package::Gem::Data.process_extensions_map(input_hash).should == {'name' => {'all' => [{:name => 'dep'}]}}
  end
  
  it "should be able to process a gem entry with multiple deps" do
    input_hash =  {'name' => ['dep1', 'dep2']}
    DpkgTools::Package::Gem::Data.process_extensions_map(input_hash).should == {'name' => {'all' => [{:name => 'dep1'}, {:name => 'dep2'}]}}
  end
  
  it "should be able to process a gem entry where the version is processed into a Float" do
    input_hash =  {'name' => {1.0 => 'dep'}}
    DpkgTools::Package::Gem::Data.process_extensions_map(input_hash).should == {'name' => {'1.0' => [{:name => 'dep'}]}}
  end
  
  it "should be able to process a gem entries with multiple deps and a mixed style" do
    input_hash =  {'mysql' => {2.6 => 'libmysqlclient-dev', 2.7 => ['libmysqlclient-dev', 'other-dep']}}
    expected_hash = {'mysql' => {'2.6' => [{:name => 'libmysqlclient-dev'}], '2.7' => [{:name => 'libmysqlclient-dev'}, {:name => 'other-dep'}]}}
    DpkgTools::Package::Gem::Data.process_extensions_map(input_hash).should == expected_hash
  end
end

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
                                            :summary => 'A gem', :files => :files, :extensions => [])
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
    @data.debian_arch.should == "all"
  end
  
  it "should provide report the debian architecture name as i386 if spec.extensions is not empty" do
    @spec.stubs(:extensions).returns(['extconf.rb'])
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
    DpkgTools::Package::Gem::Data.stubs(:native_extension_deps).with('gem_name', '1.0.8').returns([{:name => 'libblah-devel'}])
    @data.build_dependencies.should == [{:name => "rubygems", :requirements => [">= 0.9.4-1"]},
                                        {:name => "rake-rubygem", :requirements => [">= 0.7.0-1"]},
                                        {:name => "dpkg-tools-rubygem", :requirements => [">= #{DpkgTools::VERSION::STRING}-1"]},
                                        {:name => "whatagem-rubygem", :requirements => [">= 0.0.0-1"]},
                                        {:name => 'libblah-devel'}]
  end
  
  it "should provide access to the summary from the spec" do
    @data.summary.should == @spec.summary
  end
  
  it "should provide access to the information DpkgTools::Package::Config needs to generate the package Rakefile's path" do
    @data.rakefile_location.should == [:base_path, 'Rakefile']
  end
end
