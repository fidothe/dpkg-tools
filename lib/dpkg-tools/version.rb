module DpkgTools #:nodoc:
  module VERSION
    unless defined? MAJOR
      MAJOR  = 0
      MINOR  = 3
      TINY   = 6
      RELEASE_CANDIDATE = nil
      
      BUILD_TIME = "2008-07-02T16:00:03+01:00"
      
      STRING = [MAJOR, MINOR, TINY].join('.')
      TAG = "REL_#{[MAJOR, MINOR, TINY, RELEASE_CANDIDATE].compact.join('_')}".upcase.gsub(/\.|-/, '_')
      FULL_VERSION = "#{[MAJOR, MINOR, TINY, RELEASE_CANDIDATE].compact.join('.')} (build #{BUILD_TIME})"
      
    end
  end
  
  NAME = "dpkg-tools"
  GEM_NAME = NAME
  URL  = "http://dpkg-tools.rubyforge.org/"
  
  DESCRIPTION = "#{NAME}-#{VERSION::FULL_VERSION} - Painless OS package building\n#{URL}"
end