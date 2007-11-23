require File.dirname(__FILE__) + '/../../spec_helper'

describe DpkgTools::Package::ControlFiles, ".classes" do
  it "should return the control file classes in an array" do
    DpkgTools::Package::ControlFiles.classes.
      should == [DpkgTools::Package::ControlFiles::Changelog,
                 DpkgTools::Package::ControlFiles::Control,
                 DpkgTools::Package::ControlFiles::Copyright,
                 DpkgTools::Package::ControlFiles::Rakefile,
                 DpkgTools::Package::ControlFiles::Rules]
  end
end