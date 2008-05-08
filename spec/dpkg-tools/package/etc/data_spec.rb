require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Etc::Data do
  it "should provide access to the name of the resources subdir in the gem" do
    DpkgTools::Package::Etc::Data.resources_dirname.should == 'etc'
  end
  
  it "should return no dependencies by default" do
    DpkgTools::Package::Etc::Data.base_package_deps.should == []
  end
  
  it "should return no gem dependencies by default" do
    DpkgTools::Package::Etc::Data.base_gem_deps.should == []
  end
  
  describe DpkgTools::Package::Rails::Data, ".new" do
    it "should raise an error without any arguments" do
      lambda { DpkgTools::Package::Gem::Data.new }.should raise_error
    end
    
    it "should take the conf package's base path, then read in the deb.yml" do
      DpkgTools::Package::Etc::Data.expects(:load_package_data).with('base_path', 'deb.yml').returns({'name' => 'rails-app', 'version' => '1.0.8'})
      DpkgTools::Package::Etc::Data.expects(:process_dependencies).with({'name' => 'rails-app', 'version' => '1.0.8'}).returns(:deps)
      DpkgTools::Package::Etc::Data.new('base_path').should be_an_instance_of(DpkgTools::Package::Etc::Data)
    end
  end
  
  describe "instances" do
    before(:each) do
      package_data = {'name' => 'conf-package', 'version' => '1.0.8', 'license' => '(c) Matt 4evah', 
                      'summary' => "Matt's great configuration package"}
      DpkgTools::Package::Etc::Data.stubs(:load_package_data).with('base_path', 'deb.yml').
        returns(package_data)
      DpkgTools::Package::Etc::Data.expects(:process_dependencies).with(package_data).returns(:deps)
      @data = DpkgTools::Package::Etc::Data.new('base_path')
    end

    it "should profess to be an architecture-independent package" do
      @data.architecture_independent?.should be_true
    end
    
    it "should provide access to its install-time deps" do
      @data.dependencies.should == :deps
    end
    
    it "should provide access to its build-time deps" do
      @data.build_dependencies.should == :deps
    end
    
    it "should provide access to its name" do
      @data.name.should == 'conf-package'
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
    
    it "should provide access to its license" do
      @data.license.should == "(c) Matt 4evah"
    end
    
    it "should provide access to its summary" do
      @data.summary.should == "Matt's great configuration package"
    end
  end
end