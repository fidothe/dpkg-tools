require File.dirname(__FILE__) + '/../../spec_helper'

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
end