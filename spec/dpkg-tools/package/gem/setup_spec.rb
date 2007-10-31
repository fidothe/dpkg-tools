require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::Gem::Setup do
  # it "should be able to create the .orig.tar.gz containing a correctly named folder and the .gem" do
  #   # not really sure how to test this meaningfully
  #   #DpkgTools::Package::Gem.write_orig_tarball
  # end
  
  it "should be able to write a .gem file to the correct place" do
    DpkgTools::Package::Config.root_path = "a/path"
    mock_file = mock('mock File')
    mock_file.expects(:write).with('gem byte string')
    File.expects(:open).with('a/path/gem_name-rubygem-1.0.8/gem_name-1.0.8.gem', 'wb').yields(mock_file)
    
    DpkgTools::Package::Gem::Setup.write_gem_file(['gem_name', '1.0.8'], 'gem byte string')
  end
  
  it "should be able to retrieve a gem given its URL" do
    Gem::RemoteFetcher.fetcher.expects(:fetch_path).with(:uri).returns(:gem_byte_string)
    DpkgTools::Package::Gem::Setup.gem_file_from_uri(:uri).should == :gem_byte_string
  end
  
  it "should be able to retrieve the latest Gem:::Platform::RUBY version from a list of specs and sources " do
    specs_n_sources = [[stub('spec', :platform => Gem::Platform::WIN32), 'a_uri'], 
                       [stub('spec', :platform => Gem::Platform::RUBY), 'a_second_uri'],
                       [stub('spec', :platform => Gem::Platform::RUBY), 'a_third_uri']]
                       
    DpkgTools::Package::Gem::Setup.most_recent_spec_n_source(specs_n_sources)[1].should == 'a_second_uri'
  end
  
  it "should be able to retrieve specs and sources for a named gem" do
    mock_installer = mock('mock Gem::RemoteInstaller instance')
    mock_installer.expects(:specs_n_sources_matching).with('gem_name', anything).returns(:specs_n_sources)
    Gem::RemoteInstaller.expects(:new).returns(mock_installer)
    
    DpkgTools::Package::Gem::Setup.specs_n_sources_for_name('gem_name').should == :specs_n_sources
  end
  
  it "should be able to retrieve the most recent spec and source uri for a named gem" do
    DpkgTools::Package::Gem::Setup.expects(:most_recent_spec_n_source).with(:specs_n_sources).returns(:most_recent)
    DpkgTools::Package::Gem::Setup.expects(:specs_n_sources_for_name).with('gem_name').returns(:specs_n_sources)
    
    DpkgTools::Package::Gem::Setup.spec_n_source_for_name('gem_name').should == :most_recent
  end
  
  it "should be able to turn a byte string of a gem into a Gem::Format" do
    StringIO.expects(:new).with('gem_byte_string').returns(:string_io)
    Gem::Format.expects(:from_io).with(:string_io)
    
    DpkgTools::Package::Gem::Setup.format_from_string('gem_byte_string')
  end
  
  it "should retrieve the Gem::Format and bytes for a gem given a path to the .gem file" do
    File.expects(:read).with('path/to/package.gem').returns('gem byte string')
    DpkgTools::Package::Gem::Setup.expects(:format_from_string).with('gem byte string').returns(:format)
    
    DpkgTools::Package::Gem::Setup.format_and_file_from_path('path/to/package.gem').should == [:format, 'gem byte string']
  end
  
  it "should be able to create a new instance from a spec and source" do
    DpkgTools::Package::Gem::Setup.expects(:gem_uri_from_spec_n_source).with(:spec, 'source_uri').returns('http://a/uri/to/gem_name.gem')
    DpkgTools::Package::Gem::Setup.expects(:gem_file_from_uri).with('http://a/uri/to/gem_name.gem').returns('gem byte string')
    DpkgTools::Package::Gem::Setup.expects(:format_from_string).with('gem byte string').returns(:format)
    
    DpkgTools::Package::Gem::Data.expects(:new).with(:format).returns(:data)
    
    DpkgTools::Package::Gem::Setup.expects(:new).with(:data, 'gem byte string').returns(:instance)
    
    DpkgTools::Package::Gem::Setup.from_spec_and_source(:spec, 'source_uri').should == :instance
  end
  
  it "should be able to create a new instance from a spec and source via the cache" do
    DpkgTools::Package::Gem::Setup.expects(:cache_key_from_spec).with(:spec).returns('gem_name-1.0.8')
    
    DpkgTools::Package::Gem::Setup.dependency_cache.expects(:has_key?).with('gem_name-1.0.8').returns(false)
    
    DpkgTools::Package::Gem::Setup.expects(:from_spec_and_source).with(:spec, 'source_uri').returns(:instance)
    
    DpkgTools::Package::Gem::Setup.from_spec_and_source_via_cache(:spec, 'source_uri').should == :instance
  end
  
  it "should be able to create a new instance given a gem name, complete with DpkgTools::Package::Gem::Data" do
    DpkgTools::Package::Gem::Setup.expects(:spec_n_source_for_name).with('gem_name').returns([:spec, 'source_uri'])
    DpkgTools::Package::Gem::Setup.expects(:from_spec_and_source_via_cache).with(:spec, 'source_uri').returns(:instance)
    
    DpkgTools::Package::Gem::Setup.from_name('gem_name').should == :instance
  end
  
  it "should be able to return an instance from the cache after a cache hit from a spec and source" do
    DpkgTools::Package::Gem::Setup.expects(:cache_key_from_spec).with(:spec).returns('gem_name-1.0.8')
    
    DpkgTools::Package::Gem::Setup.dependency_cache.expects(:has_key?).with('gem_name-1.0.8').returns(true)
    DpkgTools::Package::Gem::Setup.dependency_cache.expects(:[]).with('gem_name-1.0.8').returns(:instance)
    DpkgTools::Package::Gem::Setup.from_spec_and_source_via_cache(:spec, 'source_uri').should == :instance
  end
  
  it "should be able to create a new instance, complete with DpkgTools::Package::Gem::Data, given a path to a .gem" do
    DpkgTools::Package::Gem::Data.expects(:new).with(:format).returns(:data)
    DpkgTools::Package::Gem::Setup.expects(:new).with(:data, 'gem byte string').returns(:instance)
    DpkgTools::Package::Gem::Setup.expects(:format_and_file_from_path).with('path/to/package.gem').returns([:format, 'gem byte string'])
    
    DpkgTools::Package::Gem::Setup.from_path('path/to/package.gem').should == :instance
  end
  
  it "should be able to return the most recent spec_n_source that satisfies a Gem::Requirement from a spec_n_source" do
    specs_n_sources = [[stub('spec', :platform => Gem::Platform::WIN32, :version => Gem::Version.create('1.1.8')), 'a_uri'], 
                       [stub('spec', :platform => Gem::Platform::RUBY, :version => Gem::Version.create('1.1.8')), 'a_second_uri'],
                       [stub('spec', :platform => Gem::Platform::RUBY, :version => Gem::Version.create('1.1.0')), 'a_third_uri'],
                       [stub('spec', :platform => Gem::Platform::WIN32, :version => Gem::Version.create('1.0.8')), 'a_fourth_uri'],
                       [stub('spec', :platform => Gem::Platform::RUBY, :version => Gem::Version.create('1.0.8')), 'a_fifth_uri'],
                       [stub('spec', :platform => Gem::Platform::RUBY, :version => Gem::Version.create('1.0.2')), 'a_sixth_uri'],
                       [stub('spec', :platform => Gem::Platform::RUBY, :version => Gem::Version.create('0.9.8')), 'a_seventh_uri']]
    
    requirement = Gem::Requirement.create(['< 1.1.0', '>= 1.0.0'])
    
    DpkgTools::Package::Gem::Setup.most_recent_spec_n_source_satisfying_requirement(requirement, specs_n_sources)[1].
      should == 'a_fifth_uri'
  end
  
  it "should be able to return a spec_n_source that satisfies a Gem::Requirement from a name" do
    DpkgTools::Package::Gem::Setup.expects(:most_recent_spec_n_source_satisfying_requirement).
      with(:requirement, :specs_n_sources).returns(:spec_n_source)
    DpkgTools::Package::Gem::Setup.expects(:specs_n_sources_for_name).with('gem_name').returns(:specs_n_sources)
    
    DpkgTools::Package::Gem::Setup.spec_n_source_for_name_and_requirement('gem_name', :requirement).should == :spec_n_source
  end
  
  it "should be able to create a new instance from a gem name and version requirement" do
    DpkgTools::Package::Gem::Setup.expects(:spec_n_source_for_name_and_requirement).with('gem_name', :requirement).returns([:spec, 'source_uri'])
    DpkgTools::Package::Gem::Setup.expects(:from_spec_and_source_via_cache).with(:spec, 'source_uri').returns(:instance)
    
    DpkgTools::Package::Gem::Setup.from_name_and_requirement('gem_name', :requirement).should == :instance
    # 
    # DpkgTools::Package::Gem::Data.expects(:new).with(:format).returns(:data)
    # DpkgTools::Package::Gem::Setup.expects(:new).with(:data, 'gem byte string').returns(:instance)
    # DpkgTools::Package::Gem::Setup.expects(:format_and_file_from_name_and_requirement).with('gem_name', :requirement).returns([:format, 'gem byte string'])
    # 
    # DpkgTools::Package::Gem::Setup.from_name_and_requirement('gem_name', :requirement).should == :instance
  end
  
  it "should provide access to a cache of dependencies" do
    DpkgTools::Package::Gem::Setup.dependency_cache.should be_an_instance_of(Hash)
  end
  
  it "should persist the cache store between queries" do
    DpkgTools::Package::Gem::Setup.dependency_cache.should === DpkgTools::Package::Gem::Setup.dependency_cache
  end
  
  it "should be able to generate a name, version cache key from a spec" do
    mock_spec = mock('mock Gem::Specification')
    mock_spec.expects(:name).returns('gem_name')
    mock_version = mock('mock Gem::Version')
    mock_version.expects(:to_s).returns('1.0.8')
    mock_spec.expects(:version).returns(mock_version)
    
    DpkgTools::Package::Gem::Setup.cache_key_from_spec(mock_spec).should == 'gem_name-1.0.8'
  end
end

describe DpkgTools::Package::Gem::Setup, ".new" do
  it "should raise an error without any arguments" do
    lambda { DpkgTools::Package::Gem::Setup.new }.should raise_error
  end
  
  it "should raise an error without only one argument" do
    lambda { DpkgTools::Package::Gem::Setup.new(:data) }.should raise_error
  end
  
  it "should require two arguments" do
    DpkgTools::Package::Gem::Setup.new(:data, 'gem_byte_string')
  end
end

describe DpkgTools::Package::Gem::Setup, "instances" do
  before(:each) do
    @data = stub("stub DpkgTools::Package::Gem::Data", :name => 'gem_name', :version => '1.0.8', 
                 :full_name => 'gem_name-1.0.8', :config_key => ['gem_name', '1.0.8'])
    @setup = DpkgTools::Package::Gem::Setup.new(@data, 'gem byte string')
  end
  
  it "should provide access to its Package::Gem::Data" do
    @setup.data.should == @data
  end
  
  it "should provide access to its gem's byte_string" do
    @setup.gem_byte_string.should == 'gem byte string'
  end
  
  it "should be able to write a .orig.tar.gz file with the gem in" do
    DpkgTools::Package::Gem::Setup.expects(:write_orig_tarball).with(['gem_name', '1.0.8'], 'gem byte string')
    
    @setup.write_orig_tarball
  end
  
  it "should be able to write the .gem file" do
    DpkgTools::Package::Gem::Setup.expects(:write_gem_file).with(['gem_name', '1.0.8'], 'gem byte string')
    
    @setup.write_gem_file
  end
  
  it "should be able to call DpkgTools::Package::Metadata to write out the debian control files" do
    DpkgTools::Package::Metadata.expects(:write_control_files).with(@setup.data)
    @setup.write_control_files
  end
  
  it "should expose the config_key from @data" do
    @setup.config_key.should == @data.config_key
  end
  
  it "should be able to perform all the steps needed to create the package structure" do
    stub_config = stub('stub DpkgTools::Package::Config', :base_path => 'a/path/to/gem_name-1.0.8')
    DpkgTools::Package.expects(:config).at_least_once.with(['gem_name', '1.0.8']).returns(stub_config)
    
    DpkgTools::Package.expects(:check_package_dir).with('a/path/to/gem_name-1.0.8')
    
    @setup.expects(:write_orig_tarball)
    @setup.expects(:write_gem_file)
    @setup.expects(:write_control_files)
    
    @setup.create_structure
  end
  
  it "should be able to create a setup instance for a dependency which has already had its dependencies fetched" do
    mock_dep_setup = mock('mock DpkgTools::Package::Gem::Setup')
    mock_dep_setup.expects(:fetched_dependencies?).returns(true)
    DpkgTools::Package::Gem::Setup.expects(:from_name_and_requirement).
      with('gem_name', :requirement).returns(mock_dep_setup)
    mock_dependency = mock('mock Gem::Dependency')
    mock_dependency.expects(:name).returns('gem_name')
    mock_dependency.expects(:version_requirements).returns(:requirement)
    
    @setup.fetch_dependency(mock_dependency).should == mock_dep_setup
  end
  
  it "should be able to create a setup instance (and its dependencies) for a dependency" do
    mock_dep_setup = mock('mock DpkgTools::Package::Gem::Setup')
    mock_dep_setup.expects(:fetched_dependencies?).returns(false)
    mock_dep_setup.expects(:fetch_dependencies).returns([:child_dep])
    DpkgTools::Package::Gem::Setup.expects(:from_name_and_requirement).
      with('gem_name', :requirement).returns(mock_dep_setup)
    mock_dependency = mock('mock Gem::Dependency')
    mock_dependency.expects(:name).returns('gem_name')
    mock_dependency.expects(:version_requirements).returns(:requirement)
    
    @setup.fetch_dependency(mock_dependency).should == [mock_dep_setup, :child_dep]
  end
  
  it "should be able to create setup instances for any dependencies" do
    @data.expects(:dependencies).returns([:dep1, :dep2])
    @setup.expects(:fetch_dependency).with(:dep1).returns(:dep1_setup)
    @setup.expects(:fetch_dependency).with(:dep2).returns(:dep2_setup)
    @setup.fetch_dependencies.should == [:dep1_setup, :dep2_setup]
  end
  
  it "should provide access to the class dependency_cache" do
    DpkgTools::Package::Gem::Setup.expects(:dependency_cache).returns(:dependency_cache)
    @setup.dependency_cache.should == :dependency_cache
  end
  
  it "should be able to record the fact that it has fetched its dependencies" do
    @data.expects(:dependencies).returns([])
    @setup.fetch_dependencies
    @setup.fetched_dependencies?.should be_true
  end
  
  it "should be able to record the fact that it has NOT fetched its dependencies" do
    @setup.fetched_dependencies?.should be_false
  end
end