require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Gem::MetadataModules::Copyright, "#license_file" do
  it "should be able to locate and return the Gem's license file" do
    stub_data = stub('stub DpkgTools::Package::Gem::Data', :files => ["LICENSE"], 
                     :file_entries => [[{"path" => "LICENSE"}, "License file text"]])
    metadata = OpenStruct.new(:data => stub_data, :config => :config)
    metadata.extend(DpkgTools::Package::Gem::MetadataModules::Copyright)
    
    metadata.license_file.should == "License file text"
  end
end

