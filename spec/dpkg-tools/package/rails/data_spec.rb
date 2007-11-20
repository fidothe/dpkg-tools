require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Rails::Data, ".load_package_data" do
  it "should be able to read in the config/deb.yml file" do
    File.expects(:exist?).with('base_path/config/deb.yml').returns(true)
    YAML.expects(:load_file).with('base_path/config/deb.yml').returns({"name" => 'rails-app'})
    DpkgTools::Package::Rails::Data.load_package_data('base_path').should == {"name" => 'rails-app'}
  end
end

describe DpkgTools::Package::Rails::Data, ".new" do
  it "should raise an error without any arguments" do
    lambda { DpkgTools::Package::Gem::Data.new }.should raise_error
  end
  
  it "should take the rails app base path, then read in the config/deb.yml" do
    DpkgTools::Package::Rails::Data.expects(:load_package_data).with('base_path').returns({'name' => 'rails-app', 'version' => '1.0.8'})
    DpkgTools::Package::Config.expects(:new).with('rails-app', '1.0.8', :base_path => 'base_path').returns(:config)
    DpkgTools::Package::Rails::Data.new('base_path').should be_an_instance_of(DpkgTools::Package::Rails::Data)
  end
end

describe DpkgTools::Package::Rails::Data, "instances" do
  before(:each) do
    DpkgTools::Package::Rails::Data.stubs(:load_package_data).with('base_path').returns({'name' => 'rails-app', 'version' => '1.0.8'})
    @data = DpkgTools::Package::Rails::Data.new('base_path')
  end
  
  it "should provide access to its name" do
    @data.name.should == 'rails-app'
  end
  
  it "should convert the Gem::Version object to a string" do
    @data.version.should == '1.0.8'
  end
  
  it "should provide access to the changelog-derived debian_revision" do
    @data.debian_revision.should == "1"
  end
  
  it "should provide access to the debian architecture name" do
    @data.debian_arch.should == "all"
  end
  
  it "should provide access to the path where its package Rakefile should live" do
    @data.rakefile_path.should == 'base_path/lib/tasks/dpkg-tools.rake'
  end
end
