require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Etc::Setup do
  describe "bootstrapping support" do
    it "should return base_path/deb.yml when asked to return bootstrap_file_path" do
      DpkgTools::Package::Etc::Setup.bootstrap_file_path('base_path', 'deb.yml').should == 'base_path/deb.yml'
    end
  end

  it "should report deb.yml as its required bootstrap file" do
    DpkgTools::Package::Etc::Setup.bootstrap_files.should == ['deb.yml', 'changelog.yml']
  end
  
  it "should report DpkgTools::Package::Etc::Data for data_class" do
    DpkgTools::Package::Etc::Setup.data_class.should == DpkgTools::Package::Etc::Data
  end
  
  describe ".from_path" do
    it "should create a DpkgTools::Package::Etc::Data instance, and feed it to .new" do
      DpkgTools::Package::Etc::Setup.expects(:needs_bootstrapping?).with('base_path').returns(false)
      DpkgTools::Package::Etc::Data.expects(:new).with('base_path').returns(:data)
      DpkgTools::Package::Etc::Setup.expects(:new).with(:data, 'base_path').returns(:instance)
      
      DpkgTools::Package::Etc::Setup.from_path('base_path').should == :instance
    end
  end
  
  describe DpkgTools::Package::Etc::Setup, "instances" do
    before(:each) do
      @data = stub("stub DpkgTools::Package::Etc::Data", :name => 'hello', :version => '1', :base_path => 'base_path')
      @config = DpkgTools::Package::Config.new('hello', '1', {:base_path => 'base_path'})
      DpkgTools::Package::Config.expects(:new).with('hello', '1', {:base_path => 'base_path'}).returns(@config)
      
      @setup = DpkgTools::Package::Etc::Setup.new(@data)
    end
    
    it "should provide access to the correct options for making a new DpkgTools::Package::Config" do
      @setup.config_options.should == {:base_path => 'base_path'}
    end

    it "should return the right thing for #control_file_classes" do
      DpkgTools::Package::Etc::ControlFiles.expects(:classes).returns(:classes)
      @setup.control_file_classes.should == :classes
    end
    
    describe "#prepare_package" do
      it "should create an etc/ dir if it isn't already there" do
        File.stubs(:directory?).with('base_path/etc').returns(false)
        Dir.expects(:mkdir).with('base_path/etc')

        @setup.prepare_package
      end

      it "should not create the etc/ dir if it is there" do
        File.stubs(:directory?).with('base_path/etc').returns(true)
        Dir.expects(:mkdir).with('base_path/etc').never

        @setup.prepare_package
      end
    end
  end
end