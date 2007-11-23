require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::ControlFiles::Rules, "generating the debian/control file" do
  it "should return the correct filename" do
    DpkgTools::Package::ControlFiles::Rules.filename.should == 'rules'
  end
  
  it "should be an executable file" do
    DpkgTools::Package::ControlFiles::Rules.executable?.should be_true
  end
  
  it "should return the correct formatter class" do
    DpkgTools::Package::ControlFiles::Rules.formatter_class.
      should == DpkgTools::Package::ControlFiles::RulesFormatter
  end
end
