require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Gem::ControlFiles::Rakefile do
  it "should be able to generate the contents of the Rakefile" do
    config = DpkgTools::Package::Config.new("gem-name", "1.0.8", :suffix => 'rubygem')
    stub_data = stub("DpkgTools::Package::Gem::Data", :full_name => "gem-name-1.0.8")
    metadata = DpkgTools::Package::Etc::ControlFiles::Rakefile.new(stub_data, config)
    
    metadata.rakefile.should == "require 'rubygems'\n" \
    "require 'dpkg-tools'\n" \
    "\n" \
    "DpkgTools::Package::Etc::BuildTasks.new do |t|\n" \
    "  t.root_path = File.dirname(Rake.original_dir)\n" \
    "end\n"
  end
end
