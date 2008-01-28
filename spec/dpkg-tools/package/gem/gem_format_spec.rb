require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../lib/dpkg-tools/package/gem/gem_format'

describe DpkgTools::Package::Gem::GemFormat do
  before(:each) do
    klass = Class.new
    klass.send(:include, DpkgTools::Package::Gem::GemFormat)
    @module = klass.new
  end
  
  describe "creating Gem::Format objects" do
    it "should be able to turn a byte string of a gem into a Gem::Format" do
      StringIO.expects(:new).with('gem_byte_string').returns(:string_io)
      Gem::Format.expects(:from_io).with(:string_io)
    
      @module.format_from_string('gem_byte_string')
    end
    
    it "should be able to turn an old-format gem's byte string into a Gem::OldFormat" do
      StringIO.expects(:new).with(anything).returns(:string_io)
      Gem::OldFormat.expects(:from_io).with(:string_io)
      
      @module.format_from_string(File.read(File.dirname(__FILE__) + '/../../../fixtures/BlueCloth-1.0.0.gem'))
    end
  end
end