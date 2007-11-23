require File.dirname(__FILE__) + '/../../../../spec_helper'

describe DpkgTools::Package::Gem::MetadataModules::Rakefile do
  it "should be able to generate the contents of the Rakefile" do
    config = DpkgTools::Package::Config.new("gem-name", "1.0.8", :suffix => 'rubygem')
    stub_data = stub("DpkgTools::Package::Gem::Data", :full_name => "gem-name-1.0.8")
    metadata = OpenStruct.new(:data => stub_data, :config => config)
    metadata.extend(DpkgTools::Package::Gem::MetadataModules::Rakefile)
    
    metadata.rakefile.should == "require 'rubygems'\n" \
    "require 'dpkg-tools'\n" \
    "\n" \
    "DpkgTools::Package::Gem::BuildTasks.new do |t|\n" \
    "  t.root_path = File.dirname(Rake.original_dir)\n" \
    "  t.gem_path = File.join(Rake.original_dir, 'gem-name-1.0.8.gem')\n" \
    "end\n"
  end
end
