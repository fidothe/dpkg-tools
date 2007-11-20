require File.dirname(__FILE__) + '/../../../spec_helper'

require 'rake'

describe DpkgTools::Package::Rails::BuildTasks, "task creation" do
  it "should yield itself if a block is given to .new" do
    DpkgTools::Package::Rails::BuildTasks.any_instance.stubs(:define_tasks)
    
    yielded_result = nil
    result = DpkgTools::Package::Rails::BuildTasks.new do |t| 
      t.base_path = "path"
      yielded_result = t
    end
    result.should === yielded_result
  end
  
  it "should raise an error if gem_path and root_path haven't been defined" do
    lambda { DpkgTools::Package::Rails::BuildTasks.new }.should raise_error(ArgumentError)
  end
  
  it "should call #define_tasks to set up the Rake tasks on init" do
    DpkgTools::Package::Rails::BuildTasks.any_instance.expects(:define)
    
    DpkgTools::Package::Rails::BuildTasks.new do |t| 
      t.base_path = "base_path"
    end
  end
  
  it "should define the needed tasks" do
    build_tasks = DpkgTools::Package::Rails::BuildTasks.any_instance
    
    build_tasks.expects(:task).with(:clean)
    build_tasks.expects(:task).with('build-arch')
    build_tasks.expects(:task).with('build-indep')
    build_tasks.expects(:task).with(:build => ["build-arch", "build-indep"])
    build_tasks.expects(:task).with("binary-arch" => "build-arch")
    build_tasks.expects(:task).with("binary-indep" => "build-indep")
    build_tasks.expects(:task).with(:binary => ["binary-arch", "binary-indep"])
    build_tasks.expects(:task).with(:build_package)
    
    DpkgTools::Package::Rails::BuildTasks.new do |t| 
      t.base_path = "base_path"
    end
  end
end

describe DpkgTools::Package::Rails::BuildTasks, "rake tasks" do
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    
    DpkgTools::Package::Rails::BuildTasks.new do |t| 
      t.base_path = "base_path"
    end
  end
  
  after(:each) do
    Rake.application = nil
  end
  
  it "should properly call the DpkgTools::Package::Rails.create_builder from the task 'binary-arch'" do
    mock_builder = mock('mock DpkgTools::Package::Rails::Builder')
    mock_builder.expects(:build_package)
    DpkgTools::Package::Rails.expects(:create_builder).with('base_path').returns(mock_builder)
    @rake["binary-arch"].invoke
  end
  
  it "should properly call the DpkgTools::Package::Rails.create_builder from the task 'binary-indep'" do
    mock_builder = mock('mock DpkgTools::Package::Rails::Builder')
    mock_builder.expects(:build_package)
    DpkgTools::Package::Rails.expects(:create_builder).with('base_path').returns(mock_builder)
    @rake["binary-indep"].invoke
  end
  
  it "should properly remove the build and install products from the task 'clean'" do
    mock_builder = mock('mock DpkgTools::Package::Rails::Builder')
    mock_builder.expects(:remove_build_products)
    DpkgTools::Package::Rails.expects(:create_builder).with('base_path').returns(mock_builder)
    @rake["clean"].invoke
  end
end