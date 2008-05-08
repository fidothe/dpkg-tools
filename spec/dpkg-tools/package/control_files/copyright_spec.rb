require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::ControlFiles::Copyright, "generating the debian/control file" do
  it "should return the correct filename" do
    DpkgTools::Package::ControlFiles::Copyright.filename.should == 'copyright'
  end
  
  it "should return the correct formatter class" do
    DpkgTools::Package::ControlFiles::Copyright.formatter_class.
      should == DpkgTools::Package::ControlFiles::CopyrightFormatter
  end
  
  it "should be able to locate and return the app's license" do
    stub_data = stub('stub DpkgTools::Package::Data', :license => "(c) Matt Patterson 2007, All rights reserved")
    metadata = DpkgTools::Package::ControlFiles::Copyright.new(stub_data, :config)
    
    metadata.license_file.should == "(c) Matt Patterson 2007, All rights reserved"
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
