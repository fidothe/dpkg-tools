require File.dirname(__FILE__) + '/../../spec_helper'

describe DpkgTools::Package::Setup do
  describe "bootstrapping" do
    it "should report that it does NOT need bootstrapping if deb.yml is present" do
      DpkgTools::Package::Setup.expects(:bootstrap_file_path).with('base_path', 'deb.yml').returns('base_path/deb.yml')
      DpkgTools::Package::Setup.expects(:bootstrap_files).returns('deb.yml')
      File.expects(:file?).with('base_path/deb.yml').returns(true)

      DpkgTools::Package::Setup.needs_bootstrapping?('base_path').should be_false
    end
    
    it "should report that it does need bootstrapping if deb.yml is NOT present" do
      DpkgTools::Package::Setup.expects(:bootstrap_file_path).with('base_path', 'deb.yml').returns('base_path/deb.yml')
      DpkgTools::Package::Setup.expects(:bootstrap_files).returns('deb.yml')
      File.expects(:file?).with('base_path/deb.yml').returns(false)

      DpkgTools::Package::Setup.needs_bootstrapping?('base_path').should be_true
    end
    
    it "should respond to bootstrap" do
      DpkgTools::Package::Setup.should respond_to(:bootstrap)
    end
    
    it "should provide a for-overriding bootstrap_files method" do
      DpkgTools::Package::Setup.bootstrap_files.should == ['deb.yml']
    end
    
    it "should provide a for-overriding bootstrap_file_path method" do
      DpkgTools::Package::Setup.bootstrap_file_path('base_path', 'deb.yml').should == 'base_path/deb.yml'
    end
    
    describe ".bootstrap_file support methods" do
      it "should be able to report that a target file already exists" do
        File.stubs(:file?).with('target/file/path').returns(true)
        DpkgTools::Package::Setup.file_exists?('target/file/path').should be_true
      end
      
      it "should be able to report that a target file does not already exist" do
        File.stubs(:file?).with('target/file/path').returns(false)
        DpkgTools::Package::Setup.file_exists?('target/file/path').should be_false
      end
      
      it "should be able to move a target file out of the way by adding a .bak suffix" do
        FileUtils.expects(:mv).with('target/file/path', 'target/file/path.bak')
        DpkgTools::Package::Setup.move_original_aside('target/file/path')
      end
      
      it "should be able to copy a bootstrap file across to a target file path" do
        FileUtils.expects(:cp).with('source/file/path', 'target/file/path.bak')
        DpkgTools::Package::Setup.copy_bootstrap_file_across('source/file/path', 'target/file/path.bak')
      end
    end
    
    describe ".bootstrap_file" do
      before(:each) do
        DpkgTools::Package::Data.stubs(:resources_path).returns('/a/path/to/resources')
      end
      
      it "should be able to create a needed files" do
        DpkgTools::Package::Setup.expects(:bootstrap_file_path).with('base_path', 'deb.yml').returns('bootstrap_file_path')
        File.stubs(:file?).with('bootstrap_file_path').returns(false)
        
        FileUtils.expects(:cp).with('/a/path/to/resources/deb.yml', 'bootstrap_file_path')
        
        DpkgTools::Package::Setup.bootstrap_file('base_path', 'deb.yml')
      end
      
      it "should not, by default, attempt to create a file that's already there..." do
        DpkgTools::Package::Setup.expects(:bootstrap_file_path).with('base_path', 'deb.yml').returns('bootstrap_file_path')
        File.stubs(:file?).with('bootstrap_file_path').returns(true)
        
        FileUtils.expects(:cp).never
        
        DpkgTools::Package::Setup.bootstrap_file('base_path', 'deb.yml')
      end
      
      it "should be able to backup and replace a file that's already there..." do
        DpkgTools::Package::Setup.expects(:bootstrap_file_path).with('base_path', 'deb.yml').returns('bootstrap_file_path')
        File.stubs(:file?).with('bootstrap_file_path').returns(true)
        
        FileUtils.expects(:mv).with('bootstrap_file_path', 'bootstrap_file_path.bak')
        FileUtils.expects(:cp).with('/a/path/to/resources/deb.yml', 'bootstrap_file_path')
        
        DpkgTools::Package::Setup.bootstrap_file('base_path', 'deb.yml', :backup => true)
      end
    end
    
    it ".bootstrap should copy across the files correctly" do
      DpkgTools::Package::Setup.stubs(:bootstrap_files).returns('deb.yml')
      DpkgTools::Package::Setup.expects(:bootstrap_file).with('base_path', 'deb.yml')
      
      DpkgTools::Package::Setup.bootstrap('base_path')
    end
  end
  
  describe ".from_path support methods" do
    it "should provide a for-overriding method to return the Package::Data subclass to use" do
      DpkgTools::Package::Setup.data_class.should == DpkgTools::Package::Data
    end
  end
  
  describe ".from_path" do
    it "should create a DpkgTools::Package::Data instance, and feed it to .new" do
      DpkgTools::Package::Setup.expects(:needs_bootstrapping?).with('base_path').returns(false)
      DpkgTools::Package::Data.expects(:new).with('base_path').returns(:data)
      DpkgTools::Package::Setup.expects(:new).with(:data, 'base_path').returns(:instance)
                      
      DpkgTools::Package::Setup.from_path('base_path').should == :instance
    end
  
    it "should be able to bootstrap the rails app if needed" do
      DpkgTools::Package::Setup.expects(:needs_bootstrapping?).with('base_path').returns(true)
      DpkgTools::Package::Setup.expects(:bootstrap).with('base_path')
                      
      DpkgTools::Package::Data.expects(:new).with('base_path').returns(:data)
      DpkgTools::Package::Setup.expects(:new).with(:data, 'base_path').returns(:instance)
                      
      DpkgTools::Package::Setup.from_path('base_path').should == :instance
    end
  end
end

describe DpkgTools::Package::Setup, "#create_structure" do
  before(:each) do
    @data = stub("stub DpkgTools::Package::Data", :name => 'hello', :version => '1')
    DpkgTools::Package::Config.root_path = '/a/path/to/package/dirs'
    @config = DpkgTools::Package::Config.new('hello', '1', {})
    DpkgTools::Package::Config.expects(:new).with('hello', '1', {}).returns(@config)
    
    @setup = DpkgTools::Package::Setup.new(@data, :base_path => 'base_path')
  end
  
  it "should be able to provide the options needed for DpkgTools::Package::Config" do
    @setup.config_options.should == {}
  end
  
  it "should be able to perform all the steps needed to create the package structure" do
    DpkgTools::Package.expects(:check_package_dir).with(@config)
    
    @setup.expects(:prepare_package)
    @setup.expects(:write_control_files)
    @setup.expects(:copy_maintainer_script_templates)
    
    @setup.create_structure
  end
  
  it "should be able to write out the control files" do
    mock_control_file = mock('DpkgTools::Package::ControlFile::* instance')
    mock_control_file.expects(:write)
    
    mock_control_file_class = mock('DpkgTools::Package::ControlFile::* class')
    mock_control_file_class.expects(:new).with(@data, @config).returns(mock_control_file)
    
    @setup.expects(:control_file_classes).returns([mock_control_file_class])
    
    @setup.write_control_files
  end
  
  it "should be able to return a list of maintainer script template names" do
    @setup.maintainer_script_template_names.should == ['postinst.erb', 'postrm.erb', 'preinst.erb', 'prerm.erb']
  end
  
  it "should be able to copy across any of the maintainer script templates present in the resources dir" do
    @data.stubs(:resources_path).returns('/a/path/to/resources')
    File.expects(:file?).with('/a/path/to/resources/postinst.erb').returns(true)
    File.expects(:file?).with('/a/path/to/resources/postrm.erb').returns(false)
    File.expects(:file?).with('/a/path/to/resources/preinst.erb').returns(false)
    File.expects(:file?).with('/a/path/to/resources/prerm.erb').returns(true)
    
    FileUtils.expects(:cp).with('/a/path/to/resources/postinst.erb', '/a/path/to/package/dirs/hello-1/debian/postinst.erb')
    FileUtils.expects(:cp).with('/a/path/to/resources/prerm.erb', '/a/path/to/package/dirs/hello-1/debian/prerm.erb')
    
    @setup.copy_maintainer_script_templates
  end
  
  it "should provide a no-op version of prepare_package" do
    @setup.should respond_to(:prepare_package)
  end
end

describe DpkgTools::Package::Setup, "regenerating control files and maintainer scripts" do
  before(:each) do
    @data = stub("stub DpkgTools::Package::Data", :name => 'hello', :version => '1')
    DpkgTools::Package::Config.root_path = '/a/path/to/package/dirs'
    @config = DpkgTools::Package::Config.new('hello', '1', {})
    DpkgTools::Package::Config.expects(:new).with('hello', '1', {}).returns(@config)
    
    @setup = DpkgTools::Package::Setup.new(@data, :base_path => 'base_path')
  end
  
  it "should be able to regenerate the control files, saving the existing files to name.bak" do
    mock_control_file_class = mock('DpkgTools::Package::ControlFile')
    mock_control_file_class.expects(:new).with(@data, @config).returns(mock_control_file_class)
    mock_control_file_class.stubs(:needs_reset?).returns(true)
    mock_control_file_class.stubs(:file_path).returns('/a/path/to/control_file')
    @setup.stubs(:control_file_classes).returns([mock_control_file_class])
    
    mock_control_file_class.expects(:write)
    File.expects(:exist?).with('/a/path/to/control_file').returns(true)
    FileUtils.expects(:mv).with('/a/path/to/control_file', '/a/path/to/control_file.bak')
    @setup.reset_control_files
  end
  
  it "should not bother trying to back up a control file if the file is missing" do
    mock_control_file_class = mock('DpkgTools::Package::ControlFile')
    mock_control_file_class.expects(:new).with(@data, @config).returns(mock_control_file_class)
    mock_control_file_class.stubs(:needs_reset?).returns(true)
    mock_control_file_class.stubs(:file_path).returns('/a/path/to/control_file')
    @setup.stubs(:control_file_classes).returns([mock_control_file_class])
    
    File.expects(:exist?).with('/a/path/to/control_file').returns(false)
    mock_control_file_class.expects(:write)
    @setup.reset_control_files
  end
  
  it "should not try to regenerate a control file which doesn't need it" do
    mock_control_file_class = mock('DpkgTools::Package::ControlFile')
    mock_control_file_class.expects(:new).with(@data, @config).returns(mock_control_file_class)
    mock_control_file_class.stubs(:needs_reset?).returns(false)
    mock_control_file_class.stubs(:file_path).returns('/a/path/to/control_file')
    @setup.stubs(:control_file_classes).returns([mock_control_file_class])
    
    mock_control_file_class.expects(:write).never
    @setup.reset_control_files
  end
  
  it "should be able to regenerate maintainer scripts, as needed" do
    @data.stubs(:resources_path).returns('/a/path/to/resources')
    File.expects(:file?).with('/a/path/to/resources/postinst.erb').returns(true)
    File.expects(:file?).with('/a/path/to/resources/postrm.erb').returns(false)
    File.expects(:file?).with('/a/path/to/resources/preinst.erb').returns(false)
    File.expects(:file?).with('/a/path/to/resources/prerm.erb').returns(true)
    
    FileUtils.expects(:identical?).with('/a/path/to/resources/prerm.erb', 
                                        '/a/path/to/package/dirs/hello-1/debian/prerm.erb').returns(true)
    FileUtils.expects(:identical?).with('/a/path/to/resources/postinst.erb', 
                                         '/a/path/to/package/dirs/hello-1/debian/postinst.erb').returns(false)
    FileUtils.expects(:mv).with('/a/path/to/package/dirs/hello-1/debian/postinst.erb',
                                '/a/path/to/package/dirs/hello-1/debian/postinst.erb.bak')
    FileUtils.expects(:cp).with('/a/path/to/resources/postinst.erb', '/a/path/to/package/dirs/hello-1/debian/postinst.erb')
    
    @setup.reset_maintainer_script_templates
  end
end
