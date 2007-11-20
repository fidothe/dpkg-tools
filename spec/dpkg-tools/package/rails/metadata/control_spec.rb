require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Rails::MetadataModules::Control, "instances can generate the package metadata for a debian/control file" do
  before(:each) do
    stub_requirement = stub('stub Gem::Requirement', :as_list => [">= 0.0.0"])
    @mock_dep_list = [stub('stub Gem::Dependency', :name => 'whatagem', :version_requirements => stub_requirement)]
    @stub_data = stub('stub DpkgTools::Package::Rails::Data', :dependencies => @mock_dep_list, :summary => "Test rails app for testing",
                      :debian_arch => 'all')
    @stub_config = DpkgTools::Package::Config.new('rails-app', '1.0.8')
    
    @metadata = OpenStruct.new(:data => @stub_data, :config => @stub_config)
    @metadata.extend(DpkgTools::Package::Rails::MetadataModules::Control)
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
  
  it "should be able to generate a sensible list of deps" do
    @metadata.send(:base_deps, @mock_dep_list).should == [{:name => "whatagem-rubygem", :requirements => [">= 0.0.0-1"]}]
  end
  
  it "should be able to generate Build-Depends: line" do
    @metadata.build_depends.should == [{:name => "rake-rubygem", :requirements => [">= 0.7.0-1"]},
                                       {:name => "rails-rubygem", :requirement => [">= 1.2.5-1"]},
                                       {:name => "whatagem-rubygem", :requirements => [">= 0.0.0-1"]}]
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
    @metadata.depends.should == [{:name => "rake-rubygem", :requirements => [">= 0.7.0-1"]},
                                 {:name => "rails-rubygem", :requirement => [">= 1.2.5-1"]},
                                 {:name => "whatagem-rubygem", :requirements => [">= 0.0.0-1"]}]
  end
  
  it "should be able to generate the Essential: line" do
    @metadata.essential.should == "no"
  end
  
  it "should be able to generate the Description: line" do
    @metadata.description.should == "Test rails app for testing"
  end
end