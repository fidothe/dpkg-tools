require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Rails::Cap, "variables for use in Cap 2 recipes" do
  it "should be able to tell if the current dir has the app's config dir in it" do
    Dir.stubs(:entries).with('path').returns(['.', '..', 'app', 'config'])
    DpkgTools::Package::Rails::Cap.dir_contains_config?('path').should be_true
  end
  
  it "should be able to work out where the root of the app is" do
    Dir.stubs(:pwd).returns('/a/path/to/rails-app')
    DpkgTools::Package::Rails::Cap.stubs(:dir_contains_config?).returns(true)
    DpkgTools::Package::Rails::Cap.located_app_root.should == '/a/path/to/rails-app'
  end
  
  it "should be able to hunt back up the path if necessary" do
    Dir.stubs(:pwd).returns('/a/path/to/rails-app/app/models')
    DpkgTools::Package::Rails::Cap.stubs(:dir_contains_config?).with('/a/path/to/rails-app/app/models').returns(false)
    DpkgTools::Package::Rails::Cap.stubs(:dir_contains_config?).with('/a/path/to/rails-app/app').returns(false)
    DpkgTools::Package::Rails::Cap.stubs(:dir_contains_config?).with('/a/path/to/rails-app').returns(true)
    
    DpkgTools::Package::Rails::Cap.located_app_root.should == '/a/path/to/rails-app'
  end
  
  it "should raise an error if it has to hunt back to / for the app's root" do
    Dir.stubs(:pwd).returns('/a/path/to/rails-app')
    DpkgTools::Package::Rails::Cap.stubs(:dir_contains_config?).returns(false)
    
    lambda { DpkgTools::Package::Rails::Cap.located_app_root }.should raise_error(DpkgTools::Package::Rails::CannotLocateAppDir)
  end
  
  it "should be able to return a DpkgTools::Package::Rails::Data instance" do
    DpkgTools::Package::Rails::Cap.stubs(:located_app_root).returns('/a/path/to/rails-app')
    DpkgTools::Package::Rails::Data.expects(:new).with('/a/path/to/rails-app').returns(:data)
    
    DpkgTools::Package::Rails.cap.should == :data
  end
end