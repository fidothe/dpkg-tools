require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Rails::ControlFiles::Control, "instances can generate the package metadata for a debian/control file" do
  before(:each) do
    @stub_data = stub('stub DpkgTools::Package::Rails::Data', :dependencies => :deps, :build_dependencies => :build_deps, :summary => "Test rails app for testing",
                      :debian_arch => 'all')
    @stub_config = DpkgTools::Package::Config.new('rails-app', '1.0.8')
    
    @metadata = DpkgTools::Package::Rails::ControlFiles::Control.new(@stub_data, @stub_config)
  end
  
  it "should be able to return the Source: line" do
    @metadata.source.should == @stub_config.package_name
  end
  
  it "should be able to return the Maintainer: line" do
    @metadata.maintainer.should == ["Matt Patterson", "matt@reprocessed.org"]
  end
  
  it "should be able to return the Section: line" do
    @metadata.section.should == 'libs'
  end
  
  it "should be able to generate the Priority: line" do
    @metadata.priority.should == 'optional'
  end
  it "should be able to generate Build-Depends: line" do
    @metadata.build_depends.should == :build_deps
  end
  
  it "should be able to generate the Standards-Version: line" do
    @metadata.standards_version.should == DpkgTools::Package.standards_version
  end
  
  it "should be able to generate the Package: line" do
    @metadata.package.should == @stub_config.package_name
  end
  
  it "should be able to generate the Architecture: line" do
    @metadata.architecture.should == "all"
  end
  
  it "should be able to generate the Depends: line" do
    @metadata.depends.should == :deps
  end
  
  it "should be able to generate the Essential: line" do
    @metadata.essential.should == "no"
  end
  
  it "should be able to generate the Description: line" do
    @metadata.description.should == "Test rails app for testing"
  end
end