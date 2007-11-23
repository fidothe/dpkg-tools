require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Gem::ControlFiles::Control, "instances can generate the package metadata for a debian/control file" do
  before(:each) do
    stub_requirement = stub('stub Gem::Requirement', :as_list => [">= 0.0.0"])
    @mock_dep_list = [stub('stub Gem::Dependency', :name => 'whatagem', :version_requirements => stub_requirement)]
    @stub_data = stub('stub DpkgTools::Package::Gem::Data', :dependencies => @mock_dep_list, :summary => "Test gem for testing",
                      :debian_arch => 'i386')
    @stub_config = DpkgTools::Package::Config.new('gem-name', '1.0.8', :suffix => 'rubygem')
    
    @control_file = DpkgTools::Package::Gem::ControlFiles::Control.new(@stub_data, @stub_config)
  end
  
  it "should be able to return the Source: line" do
    @control_file.source.should == @stub_config.package_name
  end
  
  it "should be able to return the Maintainer: line" do
    @control_file.maintainer.should == ["Matt Patterson", "matt@reprocessed.org"]
  end
  
  it "should be able to return the Section: line" do
    @control_file.section.should == 'libs'
  end
  
  it "should be able to generate the Priority: line" do
    @control_file.priority.should == 'optional'
  end
  
  it "should be able to generate a sensible list of deps" do
    @control_file.send(:base_deps, @mock_dep_list).should == [{:name => "whatagem-rubygem", :requirements => [">= 0.0.0-1"]}]
  end
  
  it "should be able to generate Build-Depends: line" do
    @control_file.build_depends.should == [{:name => "rubygems", :requirements => [">= 0.9.4-1"]},
                                       {:name => "rake-rubygem", :requirements => [">= 0.7.0-1"]},
                                       {:name => "whatagem-rubygem", :requirements => [">= 0.0.0-1"]}]
  end
  
  it "should be able to generate the Standards-Version: line" do
    @control_file.standards_version.should == DpkgTools::Package.standards_version
  end
  
  it "should be able to generate the Package: line" do
    @control_file.package.should == @stub_config.package_name
  end
  
  it "should be able to generate the Architecture: line" do
    @control_file.architecture.should == "i386"
  end
  
  it "should be able to generate the Depends: line" do
    @control_file.depends.should == [{:name => "rubygems", :requirements => [">= 0.9.4-1"]},
                                 {:name => "whatagem-rubygem", :requirements => [">= 0.0.0-1"]}]
  end
  
  it "should be able to generate the Essential: line" do
    @control_file.essential.should == "no"
  end
  
  it "should be able to generate the Description: line" do
    @control_file.description.should == "Test gem for testing"
  end
end