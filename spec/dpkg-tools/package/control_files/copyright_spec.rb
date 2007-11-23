require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::ControlFiles::Copyright, "generating the debian/control file" do
  it "should return the correct filename" do
    DpkgTools::Package::ControlFiles::Copyright.filename.should == 'copyright'
  end
  
  it "should return the correct formatter class" do
    DpkgTools::Package::ControlFiles::Copyright.formatter_class.
      should == DpkgTools::Package::ControlFiles::CopyrightFormatter
  end
end

describe DpkgTools::Package::ControlFiles::CopyrightFormatter, "Can generate a debian/copyright file" do
  it "should grab the license_file from the metadata object" do
    metadata = mock('package metadata object')
    metadata.expects(:license_file).returns("License file")
    
    formatter = DpkgTools::Package::ControlFiles::CopyrightFormatter.new(metadata)
    formatter.build.should == "License file"
  end
end
