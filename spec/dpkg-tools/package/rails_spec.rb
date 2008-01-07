require File.dirname(__FILE__) + '/../../spec_helper'

describe DpkgTools::Package::Rails, ".create_builder" do
  it "should instantiate a Package::Gem::Data and a Package::Gem::Builder and make 'em work" do
    DpkgTools::Package::Rails::Builder.expects(:from_path).with('/a/path/to/rails-app').returns(:builder)
    
    DpkgTools::Package::Rails.create_builder('/a/path/to/rails-app').should == :builder
  end
end

describe DpkgTools::Package::Rails, ".setup_from_path" do
  it "should be able to create package structure from a path to a gem file" do
    mock_setup = mock('mock DpkgTools::Package::Rails::Setup')
    DpkgTools::Package::Rails::Setup.expects(:from_path).with('/path/to/rails-app').returns(mock_setup)
    mock_setup.expects(:create_structure)
    
    DpkgTools::Package::Rails.setup_from_path('/path/to/rails-app')
  end
end

describe DpkgTools::Package::Rails, ".create_setup" do
  it "should be able to create a Setup instance" do
    DpkgTools::Package::Rails::Setup.expects(:from_path).with('/path/to/rails-app').returns(:setup)
    
    DpkgTools::Package::Rails.create_setup('/path/to/rails-app').should == :setup
  end
end
