require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Etc::ControlFiles do
  it "should provide access to the list of control file classes" do
    DpkgTools::Package::Etc::ControlFiles.classes.
      should == [DpkgTools::Package::Etc::ControlFiles::Changelog,
                 DpkgTools::Package::ControlFiles::Control,
                 DpkgTools::Package::ControlFiles::Copyright,
                 DpkgTools::Package::Etc::ControlFiles::Rakefile,
                 DpkgTools::Package::ControlFiles::Rules]
  end
end
