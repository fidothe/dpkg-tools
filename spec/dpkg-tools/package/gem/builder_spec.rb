require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Gem::Builder do
  it "should be able to grab the bytes of a gem file and extract a Gem::Format" do
    mock_file = mock('mock File')
    mock_file.expects(:read).returns('gem byte string')
    mock_file.expects(:rewind)
    File.expects(:open).with('path/to/file.gem', 'rb').returns(mock_file)
    Gem::Format.expects(:from_io).with(mock_file)
    DpkgTools::Package::Gem::Builder.format_and_file_from_file_path('path/to/file.gem')
  end
  
  it "should be able to snarf the gem file, create a DpkgTools::Package::Gem::Data and a Builder instance" do
    DpkgTools::Package::Gem::Data.expects(:new).with(:format).returns(:data)
    DpkgTools::Package::Gem::Builder.expects(:new).with(:data, 'gem byte string').returns(:instance)
    DpkgTools::Package::Gem::Builder.expects(:format_and_file_from_file_path).with('gem_path').returns([:format, 'gem byte string'])
    
    DpkgTools::Package::Gem::Builder.from_file_path('gem_path').should == :instance
  end
end

describe DpkgTools::Package::Gem::Builder, "instances" do
  before(:each) do
    @config = DpkgTools::Package::Config.new('stub_gem', '1.0.8', :suffix => 'rubygem')
    @config.stubs(:root_path).returns("a/path/to")
    @stub_data = stub("stub DpkgTools::Package::Gem::Data", :name => 'stub_gem', :version => '1.0.8', 
                 :full_name => 'gem_name-1.0.8', :config => @config)
    
    @builder = DpkgTools::Package::Gem::Builder.new(@stub_data, 'gem byte string')
  end
  
  it "should provide access to @data" do
    @builder.data.should == @stub_data
  end
  
  it "should provide access to @gem_byte_string" do
    @builder.gem_byte_string.should == 'gem byte string'
  end
  
  it "should be able to provide access to its DpkgTools::Package::Config entry" do
    @builder.config.should == @config
  end
  
  it "should be able to create the debian/tmp buildroot dir" do
    Dir.expects(:mkdir).with('a/path/to/stub-gem-rubygem-1.0.8/debian/tmp')
    File.expects(:directory?).with('a/path/to/stub-gem-rubygem-1.0.8/debian/tmp').returns(false)
    
    @builder.create_buildroot
  end
  
  it "should be able to create the needed install dirs" do
    FileUtils.expects(:mkdir_p).with('a/path/to/stub-gem-rubygem-1.0.8/debian/tmp/usr/lib/ruby/gems/1.8')
    FileUtils.expects(:mkdir_p).with('a/path/to/stub-gem-rubygem-1.0.8/debian/tmp/usr/bin')
    
    @builder.create_install_dirs
  end
  
  it "should be able to create the buildroot/DEBIAN dir" do
    Dir.expects(:mkdir).with('a/path/to/stub-gem-rubygem-1.0.8/debian/tmp/DEBIAN')
    File.expects(:directory?).with('a/path/to/stub-gem-rubygem-1.0.8/debian/tmp/DEBIAN').returns(false)
    
    @builder.create_DEBIAN_dir
  end
  
  it "should override Gem.bindir to provide a sensible alternative" do
    @builder.override_gem_bindir
    
    ::Gem.bindir.should == "a/path/to/stub-gem-rubygem-1.0.8/debian/tmp/usr/bin"
  end
  
  it "should be able to install the gem into the buildroot" do
    @builder.expects(:override_gem_bindir)
    mock_installer = mock('mock Gem::Installer')
    mock_installer.expects(:install).with(false, 'a/path/to/stub-gem-rubygem-1.0.8/debian/tmp/usr/lib/ruby/gems/1.8')
    Gem::Installer.expects(:new).with('a/path/to/stub-gem-rubygem-1.0.8/stub_gem-1.0.8.gem', {:wrappers => true, :env_shebang => true}).
      returns(mock_installer)
    
    @builder.install_gem
  end
  
  it "should be able to install the RI and RDoc for the gem" do
    mock_doc_manager = mock('mock Gem::DocManager')
    mock_doc_manager.expects(:generate_ri)
    mock_doc_manager.expects(:generate_rdoc)
    Gem::DocManager.expects(:new).with(:installed_gem_spec).returns(mock_doc_manager)
    
    @builder.install_docs(:installed_gem_spec)
  end
  
  it "should be able to create the DEBIAN/* package metadata files" do
    @builder.expects(:sh).with('dpkg-gencontrol')
    
    @builder.create_control_files
  end
  
  it "should be able to return the filename for the built .deb package" do
    mock_data = mock('mock DpkgTools::Package::Gem::Data')
    mock_data.expects(:deb_filename).returns(:deb_filename)
    @builder.expects(:data).returns(mock_data)
    @builder.deb_filename.should == :deb_filename
  end
  
  it "should be able to generate the path to the built .deb package" do
    @builder.expects(:deb_filename).returns('deb_filename')
    
    @builder.built_deb_path.should == "a/path/to/deb_filename"
  end
  
  it "should be able to create the .deb package" do
    @builder.stubs(:built_deb_path).returns('a/path/to/stub-gem-rubygem-1.0.8-1_i386.deb')
    
    @builder.expects(:sh).with('dpkg-deb --build "a/path/to/stub-gem-rubygem-1.0.8/debian/tmp" "a/path/to/stub-gem-rubygem-1.0.8-1_i386.deb"')
    @builder.create_deb
  end
end

describe DpkgTools::Package::Gem::Builder, "#build_package" do
  it "should perform the steps needed to make a .deb and .dsc" do
    builder = DpkgTools::Package::Gem::Builder.new(:data, 'gem byte string')
    builder.expects(:create_buildroot)
    builder.expects(:create_install_dirs)
    builder.expects(:create_DEBIAN_dir)
    builder.expects(:install_gem).returns(:installed_gem_spec)
    builder.expects(:install_docs).with(:installed_gem_spec)
    builder.expects(:create_control_files)
    builder.expects(:create_deb)
    
    builder.build_package
  end
end

describe DpkgTools::Package::Gem::Builder, "#remove_build_products" do
  before(:each) do
    @config = DpkgTools::Package::Config.new('stub_gem', '1.0.8', :suffix => 'rubygem')
    @config.stubs(:root_path).returns("a/path/to")
    
    @stub_data = stub("stub DpkgTools::Package::Gem::Data", :name => 'stub_gem', :version => '1.0.8', 
                 :full_name => 'stub_gem-1.0.8', :config => @config)
    
    @builder = DpkgTools::Package::Gem::Builder.new(@stub_data, 'gem byte string')
  end
  
  it "should only try to remove build products when debian/tmp exists" do
    File.expects(:exists?).with('a/path/to/stub-gem-rubygem-1.0.8/debian/tmp').returns(false)
    FileUtils.expects(:remove_dir).never
    
    @builder.remove_build_products
  end
  
  it "should remove all the build products" do
    File.expects(:exists?).with('a/path/to/stub-gem-rubygem-1.0.8/debian/tmp').returns(true)
    FileUtils.expects(:remove_dir).with('a/path/to/stub-gem-rubygem-1.0.8/debian/tmp')
    
    @builder.remove_build_products
  end
end