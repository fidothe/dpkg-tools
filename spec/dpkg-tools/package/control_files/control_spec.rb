require File.dirname(__FILE__) + '/../../../spec_helper'

describe "generating the debian/control file" do
  describe DpkgTools::Package::ControlFiles::Control do
    it "should return the correct filename" do
      DpkgTools::Package::ControlFiles::Control.filename.should == 'control'
    end

    it "should return the correct formatter class" do
      DpkgTools::Package::ControlFiles::Control.formatter_class.
        should == DpkgTools::Package::ControlFiles::ControlFormatter
    end
    
    describe "instances" do
      before(:each) do
        stub_requirement = stub('stub Gem::Requirement', :as_list => [">= 0.0.0"])
        @mock_dep_list = [stub('stub Gem::Dependency', :name => 'whatagem', :version_requirements => stub_requirement)]
        @stub_data = stub('stub DpkgTools::Package::Data', 
                          :build_dependencies => [{:name => "build_dep", :requirements => [">= 0.9.4-1"]}], 
                          :dependencies => [{:name => "dep", :requirements => [">= 0.9.4-1"]}], 
                          :summary => "Test gem for testing", :debian_arch => 'i386')
        @stub_config = DpkgTools::Package::Config.new('gem-name', '1.0.8', :suffix => 'rubygem')

        @control_file = DpkgTools::Package::ControlFiles::Control.new(@stub_data, @stub_config)
      end

      it "should be able to return the Source: line" do
        @control_file.source.should == @stub_config.package_name
      end

      it "should be able to return the Maintainer: line" do
        @control_file.maintainer.should == ["Matt Patterson", "matt@reprocessed.org"]
      end
      it "should be able to generate Build-Depends: line" do
        @control_file.build_depends.should == @stub_data.build_dependencies
      end

      it "should be able to generate the Standards-Version: line" do
        @control_file.standards_version.should == DpkgTools::Package.standards_version
      end

      it "should be able to generate the Package: line" do
        @control_file.package.should == @stub_config.package_name
      end

      it "should be able to generate the Architecture: line" do
        @control_file.architecture.should == "i386"
      end

      it "should be able to generate the Depends: line" do
        @control_file.depends.should == @stub_data.dependencies
      end

      it "should be able to generate the Essential: line" do
        @control_file.essential.should == "no"
      end

      it "should be able to generate the Description: line" do
        @control_file.description.should == "Test gem for testing"
      end
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
    
    describe "handling dependencies lines" do
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
  end
end