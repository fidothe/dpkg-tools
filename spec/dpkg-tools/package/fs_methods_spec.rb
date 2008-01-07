require File.dirname(__FILE__) + '/../../spec_helper'

module FSMethodsContainer
  class << self
    include DpkgTools::Package::FSMethods
  end
end

describe DpkgTools::Package::FSMethods, "filesystem-related convenience methods" do
  it "should be able to make a directory that isn't there" do
    File.expects(:exists?).with('path').returns(false)
    FileUtils.expects(:mkdir_p).with('path')
    
    FSMethodsContainer.create_dir_if_needed('path')
  end
  
  it "should be able to conditionally make a directory" do
    File.expects(:exists?).with('path').returns(true)
    File.expects(:file?).with('path').returns(false)
    FileUtils.expects(:mkdir_p).never
    
    FSMethodsContainer.create_dir_if_needed('path')
  end
  
  it "should error if directory it was asked to make is an existing file" do
    File.expects(:exists?).with('path').returns(true)
    File.expects(:file?).with('path').returns(true)
    FileUtils.expects(:mkdir_p).never
    
    lambda { FSMethodsContainer.create_dir_if_needed('path') }.should raise_error
  end
  
end