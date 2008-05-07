require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Etc::Setup do
  describe "bootstrapping support" do
    it "should return base_path/deb.yml when asked to return bootstrap_file_path" do
      DpkgTools::Package::Etc::Setup.bootstrap_file_path('base_path', 'deb.yml').should == 'base_path/deb.yml'
    end
  end

  it "should report deb.yml as its required bootstrap file" do
    DpkgTools::Package::Etc::Setup.bootstrap_files.should == ['deb.yml', 'changelog.yml']
  end
  
  it "should report DpkgTools::Package::Etc::Data for data_class" do
    DpkgTools::Package::Etc::Setup.data_class.should == DpkgTools::Package::Etc::Data
  end
  
  describe ".from_path" do
    it "should create a DpkgTools::Package::Etc::Data instance, and feed it to .new" do
      DpkgTools::Package::Etc::Setup.expects(:needs_bootstrapping?).with('base_path').returns(false)
      DpkgTools::Package::Etc::Data.expects(:new).with('base_path').returns(:data)
      DpkgTools::Package::Etc::Setup.expects(:new).with(:data, 'base_path').returns(:instance)
      
      DpkgTools::Package::Etc::Setup.from_path('base_path').should == :instance
    end
  end
end