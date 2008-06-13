require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'
require 'rake/rdoctask'
require "#{File.dirname(__FILE__)}/../lib/dpkg-tools/version.rb"

# constants required for MetaProject's rubyforge releaser
PKG_NAME = DpkgTools::GEM_NAME
PKG_VERSION = DpkgTools::VERSION::STRING
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_FILES = FileList[
  '[A-Z]*',
  'lib/**/*.rb', 
  'spec/**/*',
  'stories/**/*',
  'tasks/**/*'
]

desc 'Generate RDoc'
rd = Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/output/rdoc'
  rdoc.options << '--title' << 'dpkg-tools' << '--line-numbers' << '--inline-source' << '--main' << 'README'
  rdoc.rdoc_files.include('README', 'CHANGES', 'MIT-LICENSE', 'lib/**/*.rb')
end

spec = Gem::Specification.new do |s|
  s.name = DpkgTools::NAME
  s.version = DpkgTools::VERSION::STRING
  s.summary = DpkgTools::DESCRIPTION
  s.description = <<-EOF
    dpkg-tools provides a set of tools for automating and managing the building of OS packages 
    (currently, only .debs). The idea is to make it painless, foolproof and the right kind of dull...
  EOF

  s.files = PKG_FILES.to_a
  s.require_path = 'lib'

  s.has_rdoc = true
  puts "rd.options: #{rd.options.inspect}"
  s.rdoc_options = rd.options

  s.bindir = 'bin'
  s.executables = FileList['bin/*'].to_a.collect { |file_path| File.basename(file_path)}
  s.author = "Matt Patterson"
  s.email = "matt@reprocessed.org"
  s.homepage = "http://dpkg-tools.rubyforge.org/"
  s.platform = Gem::Platform::RUBY
  s.rubyforge_project = "dpkg-tools"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

# task :verify_user do
#   raise "RUBYFORGE_USER environment variable not set!" unless ENV['RUBYFORGE_USER']
# end
# 
desc "Upload Website to RubyForge"
task :publish_website => :rdoc do
  unless DpkgTools::VERSION::RELEASE_CANDIDATE
    publisher = Rake::SshDirPublisher.new(
      "fidothe@rubyforge.org",
      "/var/www/gforge-projects/#{DpkgTools::NAME}",
      "doc/output/rdoc"
    )
    publisher.upload
  else
    puts "** Not publishing packages to RubyForge - this is a prerelease"
  end
end

desc "Make sure that the .tgz created by GemPackageTask gets renamed to .tar.gz. I know it's ridiculous, no need to tell me."
file "pkg/#{PKG_FILE_NAME}.tar.gz" => "pkg/#{PKG_FILE_NAME}.tgz" do
  mv "pkg/#{PKG_FILE_NAME}.tgz", "pkg/#{PKG_FILE_NAME}.tar.gz"
end

desc "Publish gem+tar.gz+zip on RubyForge. You must make sure lib/version.rb is aligned with the CHANGELOG file"
task :publish_gem => [:package, "pkg/#{PKG_FILE_NAME}.tar.gz"] do
  release_files = FileList[
    "pkg/#{PKG_FILE_NAME}.gem",
    "pkg/#{PKG_FILE_NAME}.tar.gz",
    "pkg/#{PKG_FILE_NAME}.zip"
  ]
  unless DpkgTools::VERSION::RELEASE_CANDIDATE
    require 'meta_project'
    require 'rake/contrib/xforge'

    Rake::XForge::Release.new(MetaProject::Project::XForge::RubyForge.new(DpkgTools::GEM_NAME)) do |xf|
      xf.user_name = 'fidothe'
      xf.files = release_files.to_a
      xf.release_name = "dpkg-tools #{DpkgTools::VERSION::STRING}"
    end
  else
    puts "SINCE THIS IS A PRERELEASE, FILES ARE UPLOADED WITH SSH, NOT TO THE RUBYFORGE FILE SECTION"

    host = "rspec-website@rubyforge.org"
    remote_dir = "/var/www/gforge-projects/#{DpkgTools::GEM_NAME}"

    publisher = Rake::SshFilePublisher.new(
      host,
      remote_dir,
      File.dirname(__FILE__),
      *release_files
    )
    publisher.upload

    puts "UPLOADED THE FOLLOWING FILES:"
    release_files.each do |file|
      name = file.match(/pkg\/(.*)/)[1]
      puts "* http://dpkg-tools.rubyforge.org/#{name}"
    end

    puts "They are not linked to anywhere, so don't forget to tell people!"
  end
end

desc "Make a new release to Rubyforge"
task :release => [:publish_gem, :publish_website]