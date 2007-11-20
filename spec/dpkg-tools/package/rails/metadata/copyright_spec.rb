require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Rails::MetadataModules::Copyright, "#license_file" do
  it "should be able to locate and return the app's license" do
    stub_data = stub('stub DpkgTools::Package::Rails::Data', :license => "(c) Matt Patterson 2007, All rights reserved")
    metadata = OpenStruct.new(:data => stub_data, :config => :config)
    metadata.extend(DpkgTools::Package::Rails::MetadataModules::Copyright)
    
    metadata.license_file.should == "(c) Matt Patterson 2007, All rights reserved"
  end
end

