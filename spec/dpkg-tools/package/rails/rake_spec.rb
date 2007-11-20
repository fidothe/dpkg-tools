require File.dirname(__FILE__) + '/../../../spec_helper'

require 'rake'

describe DpkgTools::Package::Gem::BuildTasks, "task creation" do
  it "should yield itself if a block is given to .new" do
    DpkgTools::Package::Gem::BuildTasks.any_instance.stubs(:define_tasks)
    
    yielded_result = nil
    result = DpkgTools::Package::Gem::BuildTasks.new do |t| 
      t.gem_path = "path"
      t.root_path = "path"
      yielded_result = t
    end
    result.should === yielded_result
  end
  
  it "should raise an error if gem_path and root_path haven't been defined" do
    lambda { DpkgTools::Package::Gem::BuildTasks.new }.should raise_error(ArgumentError)
  end
  
  it "should set DpkgTools::Package::Config.root_path correctly" do
    DpkgTools::Package::Gem::BuildTasks.any_instance.stubs(:define_tasks)
    
    DpkgTools::Package::Config.expects(:root_path=).with('root_path')
    
    DpkgTools::Package::Gem::BuildTasks.new do |t| 
      t.gem_path = "gem_path"
      t.root_path = "root_path"
    end
  end
  
  it "should call #define_tasks to set up the Rake tasks on init" do
    DpkgTools::Package::Gem::BuildTasks.any_instance.expects(:define)
    
    DpkgTools::Package::Gem::BuildTasks.new do |t| 
      t.gem_path = "path"
      t.root_path = "path"
    end
  end
  
  it "should define the needed tasks" do
    build_tasks = DpkgTools::Package::Gem::BuildTasks.any_instance
    
    build_tasks.expects(:task).with(:clean)
    build_tasks.expects(:task).with('build-arch')
    build_tasks.expects(:task).with('build-indep')
    build_tasks.expects(:task).with(:build => ["build-arch", "build-indep"])
    build_tasks.expects(:task).with("binary-arch" => "build-arch")
    build_tasks.expects(:task).with("binary-indep" => "build-indep")
    build_tasks.expects(:task).with(:binary => ["binary-arch", "binary-indep"])
    
    DpkgTools::Package::Gem::BuildTasks.new do |t| 
      t.gem_path = "path"
      t.root_path = "path"
    end
  end
end

describe DpkgTools::Package::Gem::BuildTasks, "rake tasks" do
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    
    DpkgTools::Package::Gem::BuildTasks.new do |t| 
      t.gem_path = "path/to/gem_file.gem"
      t.root_path = "path"
    end
  end
  
  after(:each) do
    Rake.application = nil
  end
  
  it "should properly call the DpkgTools::Package::Gem.create_builder from the task 'binary-arch'" do
    mock_builder = mock('mock DpkgTools::Package::Gem::Builder')
    mock_builder.expects(:build_package)
    DpkgTools::Package::Gem.expects(:create_builder).with('path/to/gem_file.gem').returns(mock_builder)
    @rake["binary-arch"].invoke
  end
  
  it "should properly remove the build and install products from the task 'clean'" do
    mock_builder = mock('mock DpkgTools::Package::Gem::Builder')
    mock_builder.expects(:remove_build_products)
    DpkgTools::Package::Gem.expects(:create_builder).with('path/to/gem_file.gem').returns(mock_builder)
    @rake["clean"].invoke
  end
end