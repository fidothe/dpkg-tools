require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::ControlFiles::Changelog, "generating the debian/control file" do
  it "should return the correct filename" do
    DpkgTools::Package::ControlFiles::Changelog.filename.should == 'changelog'
  end
  
  it "should return the correct formatter class" do
    DpkgTools::Package::ControlFiles::Changelog.formatter_class.
      should == DpkgTools::Package::ControlFiles::ChangelogFormatter
  end
end

describe DpkgTools::Package::ControlFiles::ChangelogFormatter, "Can generate a debian/copyright file" do
  it "should grab the license_file from the metadata object" do
    metadata = mock('package metadata object')
    metadata.expects(:changelog).returns("Changelog file")
    
    formatter = DpkgTools::Package::ControlFiles::ChangelogFormatter.new(metadata)
    formatter.build.should == "Changelog file"
  end
end