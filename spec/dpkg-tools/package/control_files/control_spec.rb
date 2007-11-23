require File.dirname(__FILE__) + '/../../../spec_helper'

describe DpkgTools::Package::ControlFiles::Control, "generating the debian/control file" do
  it "should return the correct filename" do
    DpkgTools::Package::ControlFiles::Control.filename.should == 'control'
  end
  
  it "should return the correct formatter class" do
    DpkgTools::Package::ControlFiles::Control.formatter_class.
      should == DpkgTools::Package::ControlFiles::ControlFormatter
  end
end

describe DpkgTools::Package::ControlFiles::ControlFormatter, "instances" do
  before(:each) do
    @metadata = stub("DpkgTools::Package::Blah::ControlFiles::Control", :source => 'source-package-name', 
                     :package => 'binary-package-name', :maintainer => ["Matt Patterson", "matt@reprocessed.org"])
    @formatter = DpkgTools::Package::ControlFiles::ControlFormatter.new(@metadata)
  end
  
  it "should be able to return a list of source paragraph fields" do
    @formatter.source_field_names.should be_an_instance_of(Array)
  end
  
  it "should be able to return a list of binary paragraph fields" do
    @formatter.binary_field_names.should be_an_instance_of(Array)
  end
  
  it "should be able to map field_names symbols to the .deb format version" do
    @formatter.field_names_map.should be_an_instance_of(Hash)
  end
  
  it "should be able to correctly construct a Maintainer line" do
    @formatter.maintainer.should == "Maintainer: Matt Patterson <matt@reprocessed.org>"
  end
  
  it "should be able to turn a list of deps into a correctly formatted string" do
    deps = [{:name => "a-dependency", :requirements => [">= 0.0.0-1"]}, {:name => "another-dep", :requirements => [">= 0", "<= 1"]}]
    @formatter.send(:deps_string, deps).should == "a-dependency (>= 0.0.0-1), another-dep (>= 0) (<= 1)"
  end
end

describe DpkgTools::Package::ControlFiles::ControlFormatter, "instances" do
  it "should iterate across the control file field names and insert any lines represented by methods in the metadata object" do
    metadata = stub('Gem::ControlFilesData::Control instance', :source => 'source-package-name', :package => 'binary-package-name')
    
    formatter = DpkgTools::Package::ControlFiles::ControlFormatter.new(metadata)
    formatter.build.should == "Source: source-package-name\n\nPackage: binary-package-name\n"
  end
  
  it "should be able to correctly construct a dependencies line" do
    metadata = stub('package metadata object', :depends => [{:name => "dependency", :requirements => [">= 1.0.0-1"]}])
    
    formatter = DpkgTools::Package::ControlFiles::ControlFormatter.new(metadata)
    formatter.send(:depends_line, :depends).should == "Depends: dependency (>= 1.0.0-1)"
  end
  
  it "should be able to correctly construct a dependencies line which has no requirements" do
    metadata = stub('package metadata object', :depends => [{:name => "dependency", :requirements => []}])
    
    formatter = DpkgTools::Package::ControlFiles::ControlFormatter.new(metadata)
    formatter.send(:depends_line, :depends).should == "Depends: dependency"
  end
  
  it "should be able to correctly construct a dependencies line which has requirements unset" do
    metadata = stub('package metadata object', :depends => [{:name => "dependency"}])
    
    formatter = DpkgTools::Package::ControlFiles::ControlFormatter.new(metadata)
    formatter.send(:depends_line, :depends).should == "Depends: dependency"
  end
  
  it "should be able to handle fields which need special processing by calling the local method and handing off the metadata to that" do
    metadata = stub('package metadata object', :depends => [{:name => "dependency", :requirements => [">= 1.0.0-1"]}])
    formatter = DpkgTools::Package::ControlFiles::ControlFormatter.new(metadata)
    
    formatter.expects(:depends_line).with(:depends).returns("Here is a depends line")
    
    formatter.build.should == "\nHere is a depends line\n"
  end
end
