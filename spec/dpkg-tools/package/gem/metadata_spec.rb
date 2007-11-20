require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Gem::Metadata, "creating instances" do
  it "should be supplied a DpkgTools::Package::Gem::Data and a DpkgTools::Package::Config" do
    metadata = DpkgTools::Package::Gem::Metadata.new(:gem_data, :config)
    
    metadata.should be_an_instance_of(DpkgTools::Package::Gem::Metadata)
    metadata.send(:data).should == :gem_data
    metadata.send(:config).should == :config
  end
end

