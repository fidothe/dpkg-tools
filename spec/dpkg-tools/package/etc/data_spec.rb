require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Etc::Data do
  it "should provide access to the name of the resources subdir in the gem" do
    DpkgTools::Package::Etc::Data.resources_dirname.should == 'etc'
  end
  
  describe "instances" do
    before(:each) do
      @data = DpkgTools::Package::Etc::Data.new
    end

    it "should profess to be an architecture-independent package" do
      @data.architecture_independent?.should be_true
    end
    
    it "should return no dependencies by default" do
      @data.dependencies.should == []
    end
    
    it "should return no build_dependencies by default" do
      @data.build_dependencies.should == []
    end
  end
end