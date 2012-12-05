# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "vbox-ng"
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrey \"Zed\" Zaikin"]
  s.date = "2012-12-05"
  s.description = "Create/start/stop/reboot/modify dozens of VirtualBox VMS with one short command."
  s.email = "zed.0xff@gmail.com"
  s.executables = ["vbox"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/vbox",
    "lib/vbox-ng.rb",
    "lib/vbox.rb",
    "lib/vbox/api41.rb",
    "lib/vbox/cli.rb",
    "lib/vbox/cmdlineapi.rb",
    "lib/vbox/vm.rb",
    "spec/spec_helper.rb",
    "spec/vm_spec.rb",
    "vbox-ng.gemspec"
  ]
  s.homepage = "http://github.com/zed-0xff/vbox-ng"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "A comfortable way of doing common VirtualBox tasks."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<awesome_print>, ["~> 1.1.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.12.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
    else
      s.add_dependency(%q<awesome_print>, ["~> 1.1.0"])
      s.add_dependency(%q<rspec>, ["~> 2.12.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    end
  else
    s.add_dependency(%q<awesome_print>, ["~> 1.1.0"])
    s.add_dependency(%q<rspec>, ["~> 2.12.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
  end
end

