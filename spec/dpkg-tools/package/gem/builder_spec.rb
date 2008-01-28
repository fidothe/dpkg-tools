require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Gem::Builder do
  it "should be able to grab the bytes of a gem file and extract a Gem::Format" do
    mock_file = mock('mock File')
    mock_file.expects(:read).returns('gem byte string')
    File.expects(:open).with('path/to/file.gem', 'rb').returns(mock_file)
    DpkgTools::Package::Gem::Builder.expects(:format_from_string).with('gem byte string')
    DpkgTools::Package::Gem::Builder.format_and_file_from_file_path('path/to/file.gem')
  end
  
  it "should be able to snarf the gem file, create a DpkgTools::Package::Gem::Data and a Builder instance" do
    data = stub('DpkgTools::Package::Gem::Data', :name => 'name', :version => 'version')
    DpkgTools::Package::Gem::Data.expects(:new).with(:format, 'gem byte string').returns(data)
    DpkgTools::Package::Gem::Builder.expects(:new).with(data).returns(:instance)
    DpkgTools::Package::Gem::Builder.expects(:format_and_file_from_file_path).with('gem_path').returns([:format, 'gem byte string'])
    
    DpkgTools::Package::Gem::Builder.from_file_path('gem_path').should == :instance
  end
end

describe DpkgTools::Package::Gem::Builder, "instances" do
  before(:each) do
    DpkgTools::Package::Config.stubs(:root_path).returns("a/path/to")
    @stub_data = stub("stub DpkgTools::Package::Gem::Data", :name => 'stub_gem', :version => '1.0.8', 
                 :full_name => 'gem_name-1.0.8', :debian_revision => '1',
                 :debian_arch => 'all', :gem_byte_string => 'gem byte string')
    
    @builder = DpkgTools::Package::Gem::Builder.new(@stub_data)
  end
  
  it "should provide the right options for DpkgTools::Package::Config" do
    @builder.config_options.should == {:suffix => 'rubygem'}
  end
  
  it "should provide access to @gem_byte_string" do
    @builder.gem_byte_string.should == 'gem byte string'
  end
  
  it "should be able to create the needed install dirs" do
    @builder.expects(:create_dir_if_needed).with('a/path/to/stub-gem-rubygem-1.0.8/debian/tmp/usr/lib/ruby/gems/1.8')
    @builder.expects(:create_dir_if_needed).with('a/path/to/stub-gem-rubygem-1.0.8/debian/tmp/usr/bin')
    
    @builder.create_install_dirs
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
  
  it "should be able to perform the steps needed to install all the package's files" do
    @builder.expects(:install_gem).returns(:installed_gem_spec)
    @builder.expects(:install_docs).with(:installed_gem_spec)
    
    @builder.build_package_files
  end
  
  it "should be able to perform the steps needed to finish the install all the package's files" do
    @builder.expects(:sh).with('chown -R root:root "a/path/to/stub-gem-rubygem-1.0.8/debian/tmp"')
    
    @builder.install_package_files
  end
end