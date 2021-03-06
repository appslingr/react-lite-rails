begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

def copy_react_asset(webpack_file, destination_file)
  full_webpack_path = File.expand_path("../react-builds/build/#{webpack_file}", __FILE__)
  full_destination_path = File.expand_path("../lib/assets/react-source/#{destination_file}", __FILE__)
  FileUtils.cp(full_webpack_path, full_destination_path)
end

namespace :react_lite do
  desc "Run the JS build process to put files in the gem source"
  task update: [:install, :build, :copy]

  desc "Build the JS bundles with Webpack"
  task :build do
    Dir.chdir("react-builds") do
      `yarn run build`
    end
  end

  desc "Copy browser-ready JS files to the gem's asset paths"
  task :copy do
    environments = ["development", "production"]
    environments.each do |environment|
      # Without addons:
      copy_react_asset("#{environment}/react-lite-browser.js", "#{environment}/react-lite.js")

      # With addons:
      copy_react_asset("#{environment}/react-lite-browser-with-addons.js", "#{environment}-with-addons/react-lite.js")
    end
  end

  desc "Install the JavaScript dependencies"
  task :install do
    Dir.chdir("react-builds") do
      `yarn install --ignore-optional`
    end
  end
end

require 'appraisal'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = ENV['TEST_PATTERN'] || 'test/**/*_test.rb'
  t.verbose = ENV['TEST_VERBOSE'] == '1'
  t.warning = false
end

task default: :test
