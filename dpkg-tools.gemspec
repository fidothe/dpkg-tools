--- !ruby/object:Gem::Specification 
name: dpkg-tools
version: !ruby/object:Gem::Version 
  version: 0.3.2
platform: ruby
authors: 
- Matt Patterson
autorequire: 
bindir: bin
cert_chain: []

date: 2008-05-08 18:11:00 +00:00
default_executable: dpkg-rails
dependencies: []

description: dpkg-tools does stuff
email: matt@reprocessed.org
executables: 
- dpkg-gem
- dpkg-rails
- dpkg-etc
extensions: []

extra_rdoc_files: 
files: 
- bin/dpkg-etc
- bin/dpkg-gem
- bin/dpkg-rails
- lib/dpkg-tools/command_line.rb
- lib/dpkg-tools/package/builder.rb
- lib/dpkg-tools/package/config.rb
- lib/dpkg-tools/package/control_files/base.rb
- lib/dpkg-tools/package/control_files/changelog.rb
- lib/dpkg-tools/package/control_files/control.rb
- lib/dpkg-tools/package/control_files/copyright.rb
- lib/dpkg-tools/package/control_files/rakefile.rb
- lib/dpkg-tools/package/control_files/rules.rb
- lib/dpkg-tools/package/control_files.rb
- lib/dpkg-tools/package/data.rb
- lib/dpkg-tools/package/etc/builder.rb
- lib/dpkg-tools/package/etc/control_files/changelog.rb
- lib/dpkg-tools/package/etc/control_files/rakefile.rb
- lib/dpkg-tools/package/etc/control_files.rb
- lib/dpkg-tools/package/etc/data.rb
- lib/dpkg-tools/package/etc/rake.rb
- lib/dpkg-tools/package/etc/setup.rb
- lib/dpkg-tools/package/etc.rb
- lib/dpkg-tools/package/fs_methods.rb
- lib/dpkg-tools/package/gem/builder.rb
- lib/dpkg-tools/package/gem/control_files/changelog.rb
- lib/dpkg-tools/package/gem/control_files/copyright.rb
- lib/dpkg-tools/package/gem/control_files/rakefile.rb
- lib/dpkg-tools/package/gem/control_files.rb
- lib/dpkg-tools/package/gem/data.rb
- lib/dpkg-tools/package/gem/gem_format.rb
- lib/dpkg-tools/package/gem/rake.rb
- lib/dpkg-tools/package/gem/setup.rb
- lib/dpkg-tools/package/gem.rb
- lib/dpkg-tools/package/rails/builder.rb
- lib/dpkg-tools/package/rails/cap.rb
- lib/dpkg-tools/package/rails/control_files/changelog.rb
- lib/dpkg-tools/package/rails/control_files/rakefile.rb
- lib/dpkg-tools/package/rails/control_files.rb
- lib/dpkg-tools/package/rails/data.rb
- lib/dpkg-tools/package/rails/rake.rb
- lib/dpkg-tools/package/rails/setup.rb
- lib/dpkg-tools/package/rails.rb
- lib/dpkg-tools/package/rake.rb
- lib/dpkg-tools/package/setup.rb
- lib/dpkg-tools/package.rb
- lib/dpkg-tools/version.rb
- lib/dpkg-tools.rb
- License.txt
- Rakefile
- README.txt
- resources/etc/changelog.yml
- resources/etc/deb.yml
- resources/etc/postinst.erb
- resources/etc/prerm.erb
- resources/gem/gems_to_deps.yml
- resources/rails/apache.conf.erb
- resources/rails/deb.yml
- resources/rails/deploy.rb
- resources/rails/logrotate.conf.erb
- resources/rails/mongrel_cluster.yml
- resources/rails/mongrel_cluster_init.erb
- resources/rails/postinst.erb
- resources/rails/postrm.erb
- resources/rails/preinst.erb
- spec/dpkg-tools/command_line_spec.rb
- spec/dpkg-tools/package/builder_spec.rb
- spec/dpkg-tools/package/config_spec.rb
- spec/dpkg-tools/package/control_files/base_spec.rb
- spec/dpkg-tools/package/control_files/changelog_spec.rb
- spec/dpkg-tools/package/control_files/control_spec.rb
- spec/dpkg-tools/package/control_files/copyright_spec.rb
- spec/dpkg-tools/package/control_files/rakefile_spec.rb
- spec/dpkg-tools/package/control_files/rules_spec.rb
- spec/dpkg-tools/package/control_files_spec.rb
- spec/dpkg-tools/package/data_spec.rb
- spec/dpkg-tools/package/etc/builder_spec.rb
- spec/dpkg-tools/package/etc/control_files/changelog_spec.rb
- spec/dpkg-tools/package/etc/control_files/rakefile_spec.rb
- spec/dpkg-tools/package/etc/control_files_spec.rb
- spec/dpkg-tools/package/etc/data_spec.rb
- spec/dpkg-tools/package/etc/rake_spec.rb
- spec/dpkg-tools/package/etc/setup_spec.rb
- spec/dpkg-tools/package/etc_spec.rb
- spec/dpkg-tools/package/fs_methods_spec.rb
- spec/dpkg-tools/package/gem/builder_spec.rb
- spec/dpkg-tools/package/gem/control_files/changelog_spec.rb
- spec/dpkg-tools/package/gem/control_files/copyright_spec.rb
- spec/dpkg-tools/package/gem/control_files/rakefile_spec.rb
- spec/dpkg-tools/package/gem/control_files_spec.rb
- spec/dpkg-tools/package/gem/data_spec.rb
- spec/dpkg-tools/package/gem/gem_format_spec.rb
- spec/dpkg-tools/package/gem/rake_spec.rb
- spec/dpkg-tools/package/gem/setup_spec.rb
- spec/dpkg-tools/package/gem_spec.rb
- spec/dpkg-tools/package/rails/builder_spec.rb
- spec/dpkg-tools/package/rails/cap_spec.rb
- spec/dpkg-tools/package/rails/control_files/changelog_spec.rb
- spec/dpkg-tools/package/rails/control_files/rakefile_spec.rb
- spec/dpkg-tools/package/rails/control_files_spec.rb
- spec/dpkg-tools/package/rails/data_spec.rb
- spec/dpkg-tools/package/rails/rake_spec.rb
- spec/dpkg-tools/package/rails/setup_spec.rb
- spec/dpkg-tools/package/rails_spec.rb
- spec/dpkg-tools/package/rake_spec.rb
- spec/dpkg-tools/package/setup_spec.rb
- spec/dpkg-tools/package_spec.rb
- spec/fixtures/BlueCloth-1.0.0.gem
- spec/fixtures/database.yml
- spec/spec.opts
- spec/spec_helper.rb
- tasks/rspec.rake
has_rdoc: false
homepage: http://dpkg-tools.rubyforge.org
post_install_message: 
rdoc_options: 
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
required_rubygems_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
requirements: []

rubyforge_project: dpkg-tools
rubygems_version: 1.1.1
signing_key: 
specification_version: 2
summary: dpkg-tools does stuff
test_files: []


