require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Gem::ControlFiles do
  it "should provide access to the list of control file classes" do
    DpkgTools::Package::Gem::ControlFiles.classes.
      should == [DpkgTools::Package::Gem::ControlFiles::Changelog,
                 DpkgTools::Package::Gem::ControlFiles::Control,
                 DpkgTools::Package::Gem::ControlFiles::Copyright,
                 DpkgTools::Package::Gem::ControlFiles::Rakefile,
                 DpkgTools::Package::ControlFiles::Rules]
  end
end
