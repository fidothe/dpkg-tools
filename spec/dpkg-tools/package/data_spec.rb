require File.dirname(__FILE__) + '/../../spec_helper'
require 'stringio'

describe DpkgTools::Package::Data, "instances" do
  before(:each) do
    @data = DpkgTools::Package::Data.new
  end
  
  it "should provide public access to a binding object of their context" do
    @data.binding.should be_an_instance_of(Binding)
  end
  
  it "should provide access to the path of the resources dir in the gem" do
    DpkgTools::Package::Data.resources_path.should == File.expand_path(File.dirname(__FILE__) + '/../../../resources/data')
  end
  
  it "should provide access to the name of the resources subdir in the gem" do
    DpkgTools::Package::Data.resources_dirname.should == 'data'
  end
  
  it "should provide access to the resources_path class method on instances" do
    @data.resources_path.should == DpkgTools::Package::Data.resources_path
  end
  
  it "should be able to say that it's an architecture-independent package when it is" do
    @data.stubs(:debian_arch).returns('all')
    @data.architecture_independent?.should be_true
  end
  
  it "should be able to say that it isn't an architecture-independent package when it isn't" do
    @data.stubs(:debian_arch).returns('i386')
    @data.architecture_independent?.should be_false
  end
  
  it "should be able to return the underlying build arch" do
    io = StringIO.new("amd64\n")
    IO.expects(:popen).with('dpkg-architecture -qDEB_BUILD_ARCH').returns(io)
    
    @data.build_system_architecture.should == "amd64"
  end
end

describe DpkgTools::Package::Data::YamlConfigHelpers do
  before(:each) do
    @module = Module.new
    @module.extend(DpkgTools::Package::Data::YamlConfigHelpers)
  end
  
  describe ".load_package_data" do
    it "should be able to figure out the path to a given .yml file" do
      @module.package_data_file_path('base_path', 'deb.yml').should == 'base_path/deb.yml'
    end
    
    it "should be able to read in the config/*.yml file" do
      File.expects(:exist?).with('base_path/deb.yml').returns(true)
      YAML.expects(:load_file).with('base_path/deb.yml').returns({"name" => 'rails-app'})
      @module.load_package_data('base_path', 'deb.yml').should == {"name" => 'rails-app'}
    end
  end
  
  describe ".process_dependencies" do
    it "should report the base deps if the YAML says no deps at all" do
      fixture_data = {'name' => 'rails-app', 'version' => '1.0.8', 'license' => '(c) Matt 4evah'}
      
      @module.expects(:base_gem_deps).returns([:dep_the_first])
      @module.expects(:base_package_deps).returns([:dep_the_other])
      @module.process_dependencies(fixture_data).
        should have_the_same_contents_as([:dep_the_first, :dep_the_other])
    end

    it "should report base deps plus gem deps if they're specified" do
      fixture_data = {'dependencies' => {'gem' => ['rspec' => ['>= 1.0.8']]}}

      @module.process_dependencies(fixture_data).
        should include({:name => 'rspec-rubygem', :requirements => ['>= 1.0.8-1']})
    end

    it "should report base deps plus package deps if they're specified" do
      fixture_data = {'dependencies' => {'package' => ['rspec' => ['>= 1.0.8']]}}

      @module.process_dependencies(fixture_data).
        should include({:name => 'rspec', :requirements => ['>= 1.0.8']})
    end

    it "should be able to report base deps plus any other deps..." do
      fixture_data = {'dependencies' => {'gem' => ['rspec' => ['>= 1.0.8']],
                      'package' => ['rspec' => ['>= 1.0.8']]}}
      deps = @module.process_dependencies(fixture_data)
      deps.should include({:name => 'rspec-rubygem', :requirements => ['>= 1.0.8-1']}) 
      deps.should include({:name => 'rspec', :requirements => ['>= 1.0.8']})
    end

    it "should be able to cope with deps whose version requirements are specified by a single string" do
      fixture_data = {'dependencies' => {'gem' => ['rspec' => '>= 1.0.8']}}

      @module.process_dependencies(fixture_data).
        should include({:name => 'rspec-rubygem', :requirements => ['>= 1.0.8-1']})
    end

    it "should be able to cope with deps without version requirements" do
      fixture_data = {'dependencies' => {'gem' => ['rspec']}}

      @module.process_dependencies(fixture_data).
        should include({:name => 'rspec-rubygem'})
    end

    it "should raise an appropriate error if the dependencies collection is not a Hash (YAML collection)" do
      fixture_data = {'dependencies' => 'string'}

      lambda { @module.process_dependencies(fixture_data) }.
        should raise_error(DpkgTools::Package::DebYAMLParseError)
    end
    
    
  end

  describe @module, ".process_dependencies_by_type" do
    it "should raise an appropriate error if the dependencies gem sequence isn't a sequence" do
      fixture_data = {'gem' => 'string'}

      lambda { @module.process_dependencies_by_type(fixture_data, 'gem') }.
        should raise_error(DpkgTools::Package::DebYAMLParseError)
    end

    it "should raise an appropriate error if one of package dependencies version requirements list isn't a list or a string..." do
      fixture_data = {'package' => ['rspec' => {'>= 1.0.8' => 'blah'}]}

      lambda { @module.process_dependencies_by_type(fixture_data, 'package') }.
        should raise_error(DpkgTools::Package::DebYAMLParseError)
    end
  end
end
