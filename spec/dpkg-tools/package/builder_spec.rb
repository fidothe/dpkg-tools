require File.dirname(__FILE__) + '/../../spec_helper'

describe DpkgTools::Package::Builder, "instances" do
  before(:each) do
    DpkgTools::Package::Config.stubs(:root_path).returns('/a/path/to/')
    @config = DpkgTools::Package::Config.new('rails-app', '1.0.8', {})
    DpkgTools::Package::Config.expects(:new).with('rails-app', '1.0.8', {}).returns(@config)
    
    @stub_data = stub("stub DpkgTools::Package::Rails::Data", :name => 'rails-app', :version => '1.0.8',
                 :full_name => 'rails-app-1.0.8', :config => @config, :debian_revision => "1", :debian_architecture => "all",
                 :mongrel_ports => ['8000', '8001', '8002'])
    stub_data_binding = @stub_data.send(:binding)
    @stub_data.stubs(:binding).returns(stub_data_binding)
    
    @builder = DpkgTools::Package::Builder.new(@stub_data)
  end
  
  it "should provide access to @data" do
    @builder.data.should == @stub_data
  end
  
  it "should be able to provide access to its DpkgTools::Package::Config entry" do
    @builder.config.should == @config
  end
  
  it "should be able to create the debian/tmp buildroot dir" do
    Dir.expects(:mkdir).with('/a/path/to/rails-app-1.0.8/debian/tmp')
    File.expects(:directory?).with('/a/path/to/rails-app-1.0.8/debian/tmp').returns(false)
    
    @builder.create_buildroot
  end
  
  it "should be able to create the buildroot/DEBIAN dir" do
    Dir.expects(:mkdir).with('/a/path/to/rails-app-1.0.8/debian/tmp/DEBIAN')
    File.expects(:directory?).with('/a/path/to/rails-app-1.0.8/debian/tmp/DEBIAN').returns(false)
    
    @builder.create_DEBIAN_dir
  end
  
  it "should be able to create the DEBIAN/* package metadata files" do
    @builder.expects(:sh).with('dpkg-gencontrol')
    
    @builder.create_control_files
  end
  
  it "should be able to generate the path to the built .deb package" do
    @builder.built_deb_path.should == "/a/path/to/rails-app_1.0.8-1_all.deb"
  end
  
  it "should be able to create the .deb package" do
    @builder.stubs(:built_deb_path).returns('/a/path/to/rails-app_1.0.8-1_all.deb')
    
    @builder.expects(:sh).with('dpkg-deb --build "/a/path/to/rails-app-1.0.8/debian/tmp" "/a/path/to/rails-app_1.0.8-1_all.deb"')
    @builder.create_deb
  end
  
  it "should be able to report which maintainer scripts need to be generated" do
    Dir.expects(:entries).with('/a/path/to/rails-app-1.0.8/debian').returns(['.', '..', 'post-inst.erb', 'pre-inst.erb', 'post-inst'])
    @builder.maintainer_script_targets.should == ['post-inst', 'pre-inst']
  end
  
  it "should be able to render an erb template using data as the binding" do
    @builder.render_template("<%= mongrel_ports.inspect %>").
      should == '["8000", "8001", "8002"]'
  end
  
  it "should be able to generate a maintainer script" do
    File.expects(:read).with('/a/path/to/rails-app-1.0.8/debian/post-inst.erb').returns('template')
    mock_file = mock('File')
    mock_file.expects(:write).with('rendered template')
    File.expects(:open).with('/a/path/to/rails-app-1.0.8/debian/post-inst', 'w').yields(mock_file)
    
    @builder.expects(:render_template).with('template').returns('rendered template')
    
    @builder.generate_maintainer_script('post-inst')
  end
  
  it "should be able to generate all the maintainer scripts" do
    @builder.expects(:maintainer_script_targets).returns(['post-inst', 'pre-inst'])
    @builder.expects(:generate_maintainer_script).with('post-inst')
    @builder.expects(:generate_maintainer_script).with('pre-inst')
    
    @builder.generate_maintainer_scripts
  end
end

describe DpkgTools::Package::Builder, "#build_package" do
  it "should perform the steps needed to make a .deb and .dsc" do
    stub_data = stub("stub DpkgTools::Package::Gem::Data", :name => 'rails-app', :version => '1.0.8', 
                 :full_name => 'rails-app-1.0.8')
    builder = DpkgTools::Package::Builder.new(stub_data)
    builder.expects(:create_buildroot)
    builder.expects(:create_install_dirs)
    builder.expects(:install_package_files)
    builder.expects(:generate_maintainer_scripts)
    builder.expects(:create_DEBIAN_dir)
    builder.expects(:create_control_files)
    builder.expects(:create_deb)
    
    builder.build_package
  end
end

describe DpkgTools::Package::Builder, "#remove_build_products" do
  before(:each) do
    DpkgTools::Package::Config.stubs(:root_path).returns("a/path/to")
    
    @stub_data = stub("stub DpkgTools::Package::Gem::Data", :name => 'rails-app', :version => '1.0.8', 
                 :full_name => 'rails-app-1.0.8')
    
    @builder = DpkgTools::Package::Builder.new(@stub_data)
  end
  
  it "should only try to remove build products when debian/tmp exists" do
    File.expects(:exists?).with('a/path/to/rails-app-1.0.8/debian/tmp').returns(false)
    FileUtils.expects(:remove_dir).never
    
    @builder.remove_build_products
  end
  
  it "should remove all the build products" do
    File.expects(:exists?).with('a/path/to/rails-app-1.0.8/debian/tmp').returns(true)
    FileUtils.expects(:remove_dir).with('a/path/to/rails-app-1.0.8/debian/tmp')
    
    @builder.remove_build_products
  end
end