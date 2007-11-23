require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Rails::ControlFiles::Copyright, "#license_file" do
  it "should be able to locate and return the app's license" do
    stub_data = stub('stub DpkgTools::Package::Rails::Data', :license => "(c) Matt Patterson 2007, All rights reserved")
    metadata = DpkgTools::Package::Rails::ControlFiles::Copyright.new(stub_data, :config)
    
    metadata.license_file.should == "(c) Matt Patterson 2007, All rights reserved"
  end
end

