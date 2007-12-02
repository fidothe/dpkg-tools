require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Gem::ControlFiles::Copyright, "#license_file" do
  it "should be able to locate and return the Gem's license file" do
    stub_data = stub('stub DpkgTools::Package::Gem::Data', :files => ["LICENSE"], 
                     :file_entries => [[{"path" => "LICENSE"}, "License file text"]])
    metadata = DpkgTools::Package::Gem::ControlFiles::Copyright.new(stub_data, :config)
    
    metadata.license_file.should == "License file text"
  end
  
  it "should be able to cope with nil entries in data.files (as seen in the mysql gem)" do
    stub_data = stub('stub DpkgTools::Package::Gem::Data', :files => ["LICENSE", nil], 
                     :file_entries => [[{"path" => "LICENSE"}, "License file text"]])
    metadata = DpkgTools::Package::Gem::ControlFiles::Copyright.new(stub_data, :config)
    
    metadata.license_file.should == "License file text"
  end
  
  it "should be able to locate licenses called COPYING" do
    stub_data = stub('stub DpkgTools::Package::Gem::Data', :files => ["COPYING"], 
                     :file_entries => [[{"path" => "COPYING"}, "License file text"]])
    metadata = DpkgTools::Package::Gem::ControlFiles::Copyright.new(stub_data, :config)
    
    metadata.license_file.should == "License file text"
  end
end

