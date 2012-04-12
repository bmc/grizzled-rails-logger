#
#
# NOTE: Man pages use the 'ronn' gem. http://rtomayko.github.com/ronn/

require 'rake/clean'
require 'pathname'

PACKAGE = 'grizzled-rails-logger'
GEMSPEC = "#{PACKAGE}.gemspec"
RDOC_OUT_DIR = 'rdoc'
GH_PAGES_DIR = File.join('..', 'gh-pages')
RDOC_PUBLISH_DIR = File.join(GH_PAGES_DIR, 'apidocs')
RUBY_SRC_DIR = 'lib'
RUBY_FILES = FileList[File.join(RUBY_SRC_DIR, '**', '*.rb')]

def load_gem(spec)
  eval File.open(spec).readlines.join('')
end

def gem_name(spec)
  gem = load_gem(spec)
  version = gem.version.to_s
  "#{PACKAGE}-#{version}.gem"
end

GEM = gem_name(GEMSPEC)
CLEAN << [RDOC_OUT_DIR, GEM]

# ---------------------------------------------------------------------------
# Tasks
# ---------------------------------------------------------------------------

task :default => :build

desc "Build everything"
task :build => [:test, :gem, :doc]

desc "Synonym for 'build'"
task :all => :build

desc "Build the gem (#{GEM})"
task :gem => GEM

file GEM => RUBY_FILES + ['Rakefile', GEMSPEC] do |t|
  require 'rubygems/builder'
  if !defined? Gem
    raise StandardError.new("Gem package not defined.")
  end
  spec = eval File.new(GEMSPEC).read
  Gem::Builder.new(spec).build
end  

desc "Build the documentation, locally"
task :doc => :rdoc

file 'rdoc' => RUBY_FILES do |t|
  require 'rdoc/rdoc'
  puts('Running rdoc...')
  mkdir_p File.dirname(RDOC_OUT_DIR) unless File.exists? RDOC_OUT_DIR
  r = RDoc::RDoc.new
  r.document(['-U', '-m', "#{RUBY_SRC_DIR}/grizzled.rb", '-o', RDOC_OUT_DIR,
              RUBY_SRC_DIR])
end

desc "Install the gem"
task :install => :gem do |t|
  require 'rubygems/installer'
  puts("Installing from #{GEM}")
  Gem::Installer.new(GEM).install
end

desc "Publish the gem"
task :publish => :gem do |t|
  sh "gem push #{GEM}"
end

desc "Publish the docs. Not really of use to anyone but the author"
task :pubdoc => [:pubrdoc, :pubchangelog]

task :pubrdoc => :doc do |t|
  target = Pathname.new(RDOC_PUBLISH_DIR).expand_path.to_s
  cd RDOC_OUT_DIR do
    mkdir_p target
    cp_r '.', target
  end
end

desc "Synonym for 'pubchangelog'"
task :changelog => :pubchangelog

desc "Publish the change log. Not really of use to anyone but the author"
task :pubchangelog do |t|
  File.open(File.join(GH_PAGES_DIR, 'CHANGELOG.md'), 'w') do |f|
    f.write <<EOF
---
title: Change Log for Grizzled Rails Logger
layout: default
---

EOF
    f.write File.open('CHANGELOG.md').read
    f.close
  end
end

task :pub

desc "Alias for 'docpub'"
task :docpub => :pubdoc

desc "Run the unit tests"
task :test do |t|
  FileList[File.join('test', '**', 't[cs]_*.rb')].each do |tf|
    cd File.dirname(tf) do |dir|
      ruby File.basename(tf)
    end
  end
end
