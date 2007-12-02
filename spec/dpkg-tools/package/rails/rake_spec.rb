require File.dirname(__FILE__) + '/../../../spec_helper'

require 'rake'

describe DpkgTools::Package::Rails::BuildTasks, "task creation" do
  it "check_setup should be fine if base_path is defined" do
    DpkgTools::Package::Rails::BuildTasks.any_instance.stubs(:define_tasks)
    DpkgTools::Package::Rails::BuildTasks.any_instance.stubs(:define_base_tasks)
    
    result = DpkgTools::Package::Rails::BuildTasks.new do |t| 
      t.base_path = 'path'
    end
    result.base_path.should == 'path'
  end
  
  it "should raise an error if base_path hasn't been defined" do
    DpkgTools::Package::Rails::BuildTasks.any_instance.stubs(:define_tasks)
    DpkgTools::Package::Rails::BuildTasks.any_instance.stubs(:define_base_tasks)
    
    lambda { DpkgTools::Package::Rails::BuildTasks.new }.should raise_error(ArgumentError)
  end
  
  it "should define the needed tasks" do
    build_tasks = DpkgTools::Package::Rails::BuildTasks.new do |t| 
      t.base_path = 'path'
    end
    
    build_tasks.expects(:task).with("binary-arch")
    build_tasks.expects(:task).with("binary-indep")
    
    build_tasks.define_tasks
  end
  
  it "should be able to return a properly instantiated Builder from create_builder" do
    build_tasks = DpkgTools::Package::Rails::BuildTasks.new do |t| 
      t.base_path = 'path'
    end
    
    DpkgTools::Package::Rails.expects(:create_builder).with('path').returns(:builder)
    
    build_tasks.create_builder.should == :builder
  end
end

describe DpkgTools::Package::Rails::BuildTasks, "rake tasks" do
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    
    @build_tasks = DpkgTools::Package::Rails::BuildTasks.new do |t| 
      t.base_path = "base_path"
    end
  end
  
  after(:each) do
    Rake.application = nil
  end
  
  it "should properly call the DpkgTools::Package::Rails.create_builder from the task 'binary-arch'" do
    mock_builder = mock('mock DpkgTools::Package::Rails::Builder')
    mock_builder.expects(:binary_package)
    @build_tasks.expects(:create_builder).returns(mock_builder)
    @rake["binary-arch"].invoke
  end
  
  it "should properly call the DpkgTools::Package::Rails.create_builder from the task 'binary-indep'" do
    mock_builder = mock('mock DpkgTools::Package::Rails::Builder')
    mock_builder.expects(:binary_package)
    @build_tasks.expects(:create_builder).returns(mock_builder)
    @rake["binary-indep"].invoke
  end
end