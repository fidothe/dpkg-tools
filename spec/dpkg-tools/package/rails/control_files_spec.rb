require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Rails::ControlFiles do
  it "should provide access to the list of control file classes" do
    DpkgTools::Package::Rails::ControlFiles.classes.
      should == [DpkgTools::Package::Rails::ControlFiles::Changelog,
                 DpkgTools::Package::ControlFiles::Control,
                 DpkgTools::Package::Rails::ControlFiles::Copyright,
                 DpkgTools::Package::Rails::ControlFiles::Rakefile,
                 DpkgTools::Package::ControlFiles::Rules]
  end
end
