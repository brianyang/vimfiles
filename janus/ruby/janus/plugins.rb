require 'rake'
require 'open-uri'

module Janus
  include Rake::DSL if defined?(Rake::DSL)

  def self.included(base)
    # Load all plugin installation tasks
    Dir["#{vim_path}/*/tasks/**.rake"].each do |f|
      base.send :import, f
    end
  end

  # Install a plugin
  #
  # @param [String] The group the plugin belongs to
  # @param [String] The plugin name
  # @param [&block] The installation block
  def install_vim_plugin(group, name, &block)
    raise Janus::BlockNotGivenError unless block_given?

    define_install_plugin_tasks(group, name, &block)
  end

  # Download and save file
  #
  # @param [String] url
  # @param [String] path
  def download_and_save_file(url, path)
    proxy = ENV['http_proxy'] || ENV['HTTP_PROXY']
    open_and_save_file(path, open(url, :proxy => proxy).read)
  end

  # Open and save file
  #
  # @param [String] path
  # @param [Value] What to write in the file
  # @param [&block]
  def open_and_save_file(path, value = nil, &block)
    # Make sure the directory up to the folder exists
    mkdir_p File.dirname(path)
    # Open the file and use either the block or the value to write the
    # file
    File.open path, 'w' do |f|
      if block_given?
        f.write(yield)
      else
        f.write(value)
      end
    end
  end

  protected

  # Define tasks for installing a plugin
  #
  # @param [String] The group the plugin belongs to
  # @param [String] The plugin name
  # @param [&block] The installation block
  def define_install_plugin_tasks(group, name, &block)
    # Create a namespace for the plugin
    namespace(name) do
      # Define the plugin installation task
      desc "Install #{name} plugin."
      task :install do
        puts
        puts "*" * 40
        puts "*#{"Installing #{name}".center(38)}*"
        puts "*" * 40
        puts
        yield(Dir["#{vim_path}/#{group}/#{name}/**"].any?)
      end
    end

    # Hook the plugin's install task to the global install task
    task :install => "#{name}:install"
  end
end
