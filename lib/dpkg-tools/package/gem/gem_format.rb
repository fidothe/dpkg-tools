require 'rubygems/old_format'
require 'rubygems/format'

module DpkgTools::Package::Gem::GemFormat
  def format_from_string(gem_byte_string)
    gem_io = StringIO.new(gem_byte_string)
    return ::Gem::OldFormat.from_io(gem_io) if gem_byte_string[0,20].include?("MD5SUM =")
    ::Gem::Format.from_io(gem_io)
  end
end