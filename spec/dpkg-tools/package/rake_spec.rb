require File.dirname(__FILE__) + '/../../spec_helper'

describe DpkgTools::Package::BuildTasks, "task creation" do
  it "should yield itself if a block is given to .new" do
    DpkgTools::Package::BuildTasks.any_instance.stubs(:define_tasks)
    
    yielded_result = nil
    result = DpkgTools::Package::BuildTasks.new do |t| 
      yielded_result = t
    end
    result.should === yielded_result
  end
  
  it "should call the necessary methods to set up the base and subclass Rake tasks on init" do
    DpkgTools::Package::BuildTasks.any_instance.expects(:check_setup)
    DpkgTools::Package::BuildTasks.any_instance.expects(:define_tasks)
    DpkgTools::Package::BuildTasks.any_instance.expects(:define_base_tasks)
                      
    DpkgTools::Package::BuildTasks.new
  end
end

describe DpkgTools::Package::BuildTasks, "instances" do
  before(:each) do
    @rake = Rake::Application.new
    Rake.application = @rake
    
    @build_tasks = DpkgTools::Package::BuildTasks.new
    @mock_builder = stub('DpkgTools::Package::Builder')
    @build_tasks.stubs(:create_builder).returns(@mock_builder)
  end
  
  after(:each) do
    Rake.application = nil
  end
  
  it "should define the needed base tasks" do
    @build_tasks.expects(:task).with(:clean)
    @build_tasks.expects(:task).with('build-arch')
    @build_tasks.expects(:task).with('build-indep')
    @build_tasks.expects(:task).with(:build)
    @build_tasks.expects(:task).with("binary-arch")
    @build_tasks.expects(:task).with("binary-indep")
    @build_tasks.expects(:task).with(:binary)
    
    @build_tasks.define_base_tasks
  end
  
  it "should invoke binary-arch from :binary when the builder says it's an arch package" do
    @mock_builder.expects(:architecture_independent?).returns(false)
    
    @rake['binary-arch'].expects(:invoke)
    @rake['binary'].invoke
  end
  
  it "should invoke binary-indep from :binary when the builder says it's an arch-indep package" do
    @mock_builder.expects(:architecture_independent?).returns(true)
    
    @rake['binary-indep'].expects(:invoke)
    @rake['binary'].invoke
  end
  
  it "should invoke build-arch from :build when the builder says it's an arch package" do
    @mock_builder.expects(:architecture_independent?).returns(false)
    
    @rake['build-arch'].expects(:invoke)
    @rake['build'].invoke
  end
  
  it "should invoke build-indep from :build when the builder says it's an arch-indep package" do
    @mock_builder.expects(:architecture_independent?).returns(true)
    
    @rake['build-indep'].expects(:invoke)
    @rake['build'].invoke
  end
end