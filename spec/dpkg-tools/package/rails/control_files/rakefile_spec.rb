require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Rails::ControlFiles::Rakefile do
  before(:each) do
    config = DpkgTools::Package::Config.new("rails-app", "1.0.8", :base_path => '/a/path/to/app')
    stub_data = stub("DpkgTools::Package::Rails::Data", :full_name => "rails-app-1.0.8")
    @control_file = DpkgTools::Package::Rails::ControlFiles::Rakefile.new(stub_data, config)
  end
  
  it "should be able to generate the contents of the Rakefile" do
    @control_file.rakefile.should == "require 'rubygems'\n" \
    "require 'dpkg-tools'\n" \
    "\n" \
    "DpkgTools::Package::Rails::BuildTasks.new do |t|\n" \
    "  t.base_path = Rake.original_dir\n" \
    "end\n"
  end
end
