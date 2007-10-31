require File.dirname(__FILE__) + '/../../spec_helper'

describe DpkgTools::Package::Gem do
  before(:each) do
    @setup = mock('mock DpkgTools::Package::Gem::Setup')
  end
  
  it "should be able to create package structure from a path to a gem file" do
    DpkgTools::Package::Gem::Setup.expects(:from_path).with('path/to/stub.gem').returns(@setup)
    @setup.expects(:create_structure)
    
    DpkgTools::Package::Gem.setup_from_path('path/to/stub.gem', {:ignore_dependencies => true})
  end
  
  it "should be able to create package structure from a path to a gem file, ignoring dependency-related options" do
    DpkgTools::Package::Gem::Setup.expects(:from_path).with('path/to/stub.gem').returns(@setup)
    @setup.expects(:create_structure)
    
    DpkgTools::Package::Gem.setup_from_path('path/to/stub.gem', {:ignore_dependencies => false})
  end
  
  it "should be able to create package structure from the name of a gem" do
    DpkgTools::Package::Gem::Setup.expects(:from_name).with('stub_gem').returns(@setup)
    @setup.expects(:create_structure)
    
    DpkgTools::Package::Gem.setup_from_name('stub_gem', {:ignore_dependencies => true})
  end
  
  it "should be able to create package structure and fetch dependencies" do
    DpkgTools::Package::Gem::Setup.expects(:from_name).with('stub_gem').returns(@setup)
    mock_dependency_setup = mock('mock DpkgTools::Package::Gem::Setup for dependency')
    mock_dependency_setup.expects(:create_structure)
    
    @setup.expects(:fetch_dependencies).returns([mock_dependency_setup])
    @setup.expects(:create_structure)
    
    DpkgTools::Package::Gem.setup_from_name('stub_gem', {})
  end
end

describe DpkgTools::Package::Gem, ".create_builder" do
  it "should instantiate a Package::Gem::Data and a Package::Gem::Builder and make 'em work" do
    DpkgTools::Package::Gem::Builder.expects(:from_file_path).with('a/path/to/stub_gem-1.1.0/stub_gem-1.1.0.gem').returns(:builder)
    
    DpkgTools::Package::Gem.create_builder('a/path/to/stub_gem-1.1.0/stub_gem-1.1.0.gem').should == :builder
  end
end