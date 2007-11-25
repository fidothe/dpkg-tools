require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Rails::Data, ".load_package_data" do
  it "should be able to read in the config/*.yml file" do
    File.expects(:exist?).with('base_path/config/deb.yml').returns(true)
    YAML.expects(:load_file).with('base_path/config/deb.yml').returns({"name" => 'rails-app'})
    DpkgTools::Package::Rails::Data.load_package_data('base_path', 'deb.yml').should == {"name" => 'rails-app'}
  end
end

describe DpkgTools::Package::Rails::Data, ".new" do
  it "should raise an error without any arguments" do
    lambda { DpkgTools::Package::Gem::Data.new }.should raise_error
  end
  
  it "should take the rails app base path, then read in the config/deb.yml" do
    DpkgTools::Package::Rails::Data.expects(:load_package_data).with('base_path', 'deb.yml').returns({'name' => 'rails-app', 'version' => '1.0.8'})
    DpkgTools::Package::Rails::Data.expects(:load_package_data).with('base_path', 'mongrel_cluster.yml').returns({'port' => '8000', 'servers' => 3})
    DpkgTools::Package::Rails::Data.expects(:process_dependencies).with({'name' => 'rails-app', 'version' => '1.0.8'}).returns(:deps)
    DpkgTools::Package::Rails::Data.new('base_path').should be_an_instance_of(DpkgTools::Package::Rails::Data)
  end
end

describe DpkgTools::Package::Rails::Data, "instances" do
  before(:each) do
    package_data = {'name' => 'rails-app', 'version' => '1.0.8', 'license' => '(c) Matt 4evah', 'summary' => "Matt's great Rails app"}
    DpkgTools::Package::Rails::Data.stubs(:load_package_data).with('base_path', 'deb.yml').
      returns(package_data)
    mongrel_cluster_data = {'port' => '8000', 'servers' => 3}
    DpkgTools::Package::Rails::Data.expects(:load_package_data).with('base_path', 'mongrel_cluster.yml').returns(mongrel_cluster_data)
    DpkgTools::Package::Rails::Data.expects(:process_dependencies).with(package_data).returns(:deps)
    @data = DpkgTools::Package::Rails::Data.new('base_path')
  end
  
  it "should provide access to its name" do
    @data.name.should == 'rails-app'
  end
  
  it "should convert the Gem::Version object to a string" do
    @data.version.should == '1.0.8'
  end
  
  it "should provide access to the changelog-derived debian_revision" do
    @data.debian_revision.should == "1"
  end
  
  it "should provide access to the debian architecture name" do
    @data.debian_arch.should == "all"
  end
  
  it "should provide access to its license" do
    @data.license.should == "(c) Matt 4evah"
  end
  
  it "should provide access to its install-time deps" do
    @data.dependencies.should == :deps
  end
  
  it "should provide access to its build-time deps" do
    @data.build_dependencies.should == :deps
  end
  
  it "should provide access to its summary" do
    @data.summary.should == "Matt's great Rails app"
  end
  
  it "should provide access to its 'full_name' equivalent" do
    @data.full_name.should == 'rails-app-1.0.8'
  end
  
  it "should provide access to its base_path" do
    @data.base_path.should == 'base_path'
  end
  
  it "should provide the rakefile_location information so the rakefile can be generated in the right place" do
    @data.rakefile_location.should == [:base_path, 'lib/tasks/dpkg-tools.rake']
  end
  
  it "should provide access to its mongrel starting port" do
    @data.mongrel_cluster_start_port.should == '8000'
  end
  
  it "should provide access to the number of mongrels specified" do
    @data.number_of_mongrels.should == 3
  end
  
  it "should provide access to an array of the port numbers to be used by the mongrels" do
    @data.mongrel_ports.should == ['8000', '8001', '8002']
  end
  
  it "should provide access to the path of the resources dir in the gem" do
    DpkgTools::Package::Rails::Data.resources_path.should == File.expand_path(File.dirname(__FILE__) + '/../../../../resources/rails')
  end
end

describe DpkgTools::Package::Rails::Data, ".process_dependencies" do
  it "should report the base deps if the YAML says no deps at all" do
    fixture_data = {'name' => 'rails-app', 'version' => '1.0.8', 'license' => '(c) Matt 4evah'}
    
    DpkgTools::Package::Rails::Data.process_dependencies(fixture_data).
      should == DpkgTools::Package::Rails::Data::BASE_GEM_DEPS \
        + DpkgTools::Package::Rails::Data::BASE_PACKAGE_DEPS
  end
  
  it "should report base deps plus gem deps if they're specified" do
    fixture_data = {'dependencies' => {'gem' => ['rspec' => ['>= 1.0.8']]}}
    
    DpkgTools::Package::Rails::Data.process_dependencies(fixture_data).
      should == DpkgTools::Package::Rails::Data::BASE_GEM_DEPS \
        + DpkgTools::Package::Rails::Data::BASE_PACKAGE_DEPS \
        + [{:name => 'rspec-rubygem', :requirements => ['>= 1.0.8-1']}]
  end
  
  it "should report base deps plus package deps if they're specified" do
    fixture_data = {'dependencies' => {'package' => ['rspec' => ['>= 1.0.8']]}}
    
    DpkgTools::Package::Rails::Data.process_dependencies(fixture_data).
      should == DpkgTools::Package::Rails::Data::BASE_GEM_DEPS \
        + DpkgTools::Package::Rails::Data::BASE_PACKAGE_DEPS \
        + [{:name => 'rspec', :requirements => ['>= 1.0.8']}]
  end
  
  it "should be able to report base deps plus any other deps..." do
    fixture_data = {'dependencies' => {'gem' => ['rspec' => ['>= 1.0.8']],
                    'package' => ['rspec' => ['>= 1.0.8']]}}
    
    DpkgTools::Package::Rails::Data.process_dependencies(fixture_data).
      should == DpkgTools::Package::Rails::Data::BASE_GEM_DEPS \
        + DpkgTools::Package::Rails::Data::BASE_PACKAGE_DEPS \
        + [{:name => 'rspec-rubygem', :requirements => ['>= 1.0.8-1']}, 
           {:name => 'rspec', :requirements => ['>= 1.0.8']}]
  end
  
  it "should be able to cope with deps whose version requirements are specified by a single string" do
    fixture_data = {'dependencies' => {'gem' => ['rspec' => '>= 1.0.8']}}
    
    DpkgTools::Package::Rails::Data.process_dependencies(fixture_data).
      should == DpkgTools::Package::Rails::Data::BASE_GEM_DEPS \
        + DpkgTools::Package::Rails::Data::BASE_PACKAGE_DEPS \
        + [{:name => 'rspec-rubygem', :requirements => ['>= 1.0.8-1']}]
  end
  
  it "should raise an appropriate error if the dependencies collection is not a Hash (YAML collection)" do
    fixture_data = {'dependencies' => 'string'}
    
    lambda { DpkgTools::Package::Rails::Data.process_dependencies(fixture_data) }.
      should raise_error(DpkgTools::Package::Rails::DebYAMLParseError)
  end
end

describe DpkgTools::Package::Rails::Data, ".process_dependencies_by_type" do
  it "should raise an appropriate error if the dependencies gem sequence isn't a sequence" do
    fixture_data = {'gem' => 'string'}
    
    lambda { DpkgTools::Package::Rails::Data.process_dependencies_by_type(fixture_data, 'gem') }.
      should raise_error(DpkgTools::Package::Rails::DebYAMLParseError)
  end
  
  it "should raise an appropriate error if one of package dependencies version requirements list isn't a list or a string..." do
    fixture_data = {'package' => ['rspec' => {'>= 1.0.8' => 'blah'}]}
    
    lambda { DpkgTools::Package::Rails::Data.process_dependencies_by_type(fixture_data, 'package') }.
      should raise_error(DpkgTools::Package::Rails::DebYAMLParseError)
  end
end


