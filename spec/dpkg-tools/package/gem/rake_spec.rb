require File.dirname(__FILE__) + '/../../../spec_helper'

require 'rake'

describe DpkgTools::Package::Gem::BuildTasks, "task creation" do
  it "check_setup should be fine if base_path is defined" do
    DpkgTools::Package::Gem::BuildTasks.any_instance.stubs(:define_tasks)
    DpkgTools::Package::Gem::BuildTasks.any_instance.stubs(:define_base_tasks)
    
    result = DpkgTools::Package::Gem::BuildTasks.new do |t| 
      t.gem_path = 'gem_path'
      t.root_path = 'root_path'
    end
    result.gem_path.should == 'gem_path'
    result.root_path.should == 'root_path'
  end
  
  it "should raise an error if gem_path and root_path haven't been defined" do
    lambda { DpkgTools::Package::Gem::BuildTasks.new }.should raise_error(ArgumentError)
  end
  
  it "should set DpkgTools::Package::Config.root_path correctly" do
    DpkgTools::Package::Gem::BuildTasks.any_instance.stubs(:define_tasks)
    DpkgTools::Package::Gem::BuildTasks.any_instance.stubs(:define_base_tasks)
    
    DpkgTools::Package::Config.expects(:root_path=).with('root_path')
    
    DpkgTools::Package::Gem::BuildTasks.new do |t| 
      t.gem_path = 'gem_path'
      t.root_path = 'root_path'
    end
  end
  
  it "should define the needed tasks" do
    build_tasks = DpkgTools::Package::Gem::BuildTasks.new do |t| 
      t.gem_path = 'gem_path'
      t.root_path = 'root_path'
    end
    
    build_tasks.expects(:task).with("binary-arch")
    build_tasks.expects(:task).with("binary-indep")
    build_tasks.expects(:task).with("build-arch")
    build_tasks.expects(:task).with("build-indep")
    
    build_tasks.define_tasks
  end
  
  it "should be able to return a properly instantiated Builder from create_builder" do
    build_tasks = DpkgTools::Package::Gem::BuildTasks.new do |t| 
      t.gem_path = 'gem_path'
      t.root_path = 'root_path'
    end
    
    DpkgTools::Package::Gem.expects(:create_builder).with('gem_path').returns(:builder)
    
    build_tasks.create_builder.should == :builder
  end
end

describe DpkgTools::Package::Gem::BuildTasks, "rake tasks" do
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    
    @build_tasks = DpkgTools::Package::Gem::BuildTasks.new do |t| 
      t.gem_path = "path/to/gem_file.gem"
      t.root_path = "path"
    end
  end
  
  after(:each) do
    Rake.application = nil
  end
  
  it "should properly call the DpkgTools::Package::Gem.create_builder from the task 'binary-arch'" do
    mock_builder = mock('mock DpkgTools::Package::Gem::Builder')
    mock_builder.expects(:binary_package)
    @build_tasks.expects(:create_builder).returns(mock_builder)
    @rake["binary-arch"].invoke
  end
  
  it "should properly call the DpkgTools::Package::Gem.create_builder from the task 'binary-indep'" do
    mock_builder = mock('mock DpkgTools::Package::Gem::Builder')
    mock_builder.expects(:binary_package)
    @build_tasks.expects(:create_builder).returns(mock_builder)
    @rake["binary-indep"].invoke
  end
  
  it "should properly call the DpkgTools::Package::Gem.create_builder from the task 'build-arch'" do
    mock_builder = mock('mock DpkgTools::Package::Gem::Builder')
    mock_builder.expects(:build_package)
    @build_tasks.expects(:create_builder).returns(mock_builder)
    @rake["build-arch"].invoke
  end
  
  it "should properly call the DpkgTools::Package::Gem.create_builder from the task 'build-indep'" do
    mock_builder = mock('mock DpkgTools::Package::Gem::Builder')
    mock_builder.expects(:build_package)
    @build_tasks.expects(:create_builder).returns(mock_builder)
    @rake["build-indep"].invoke
  end
end