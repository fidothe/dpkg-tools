require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Rails::MetadataModules::Rakefile do
  it "should be able to generate the contents of the Rakefile" do
    config = DpkgTools::Package::Config.new("rails-app", "1.0.8")
    stub_data = stub("DpkgTools::Package::Rails::Data", :full_name => "rails-app-1.0.8")
    metadata = OpenStruct.new(:data => stub_data, :config => config)
    metadata.extend(DpkgTools::Package::Rails::MetadataModules::Rakefile)
    
    metadata.rakefile.should == "require 'rubygems'\n" \
    "require 'dpkg-tools'\n" \
    "\n" \
    "DpkgTools::Package::Rails::BuildTasks.new do |t|\n" \
    "  t.base_path = Rake.original_dir\n" \
    "end\n"
  end
end
