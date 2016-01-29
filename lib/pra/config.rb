require 'json'
require 'fileutils'

module Pra
  class Config
    def initialize(initial_config = {})
      @initial_config = initial_config
      if @initial_config["log_level"]
        Pra::Log.level(@initial_config["log_level"])
      end
    end

    def self.load_config
      return self.new(self.parse_config_file)
    end

    def self.parse_config_file
      self.json_parse(self.read_config_file)
    end

    def self.read_config_file
      file = File.open(self.config_path, "r")
      contents = file.read
      file.close
      return contents
    end

    def self.config_path
      if File.exists?(File.join(self.users_home_directory, '.pra', 'config.json'))
        return File.join(self.users_home_directory, '.pra', 'config.json')
      else
        return File.join(self.users_home_directory, '.pra.json')
      end
    end

    def self.log_path
      unless Dir.exists?(File.join(self.users_home_directory, '.pra', 'logs'))
        FileUtils.mkdir_p(File.join(self.users_home_directory, '.pra', 'logs'))
      end
      return File.join(self.users_home_directory, '.pra', 'logs', '.pra.log')
    end

    def self.users_home_directory
      return ENV['HOME']
    end

    def self.json_parse(content)
      return JSON.parse(content)
    end

    def pull_sources
      @initial_config["pull_sources"]
    end

    def assignee_blacklist
      Array(@initial_config["assignee_blacklist"])
    end
    
    def refresh_interval
      @initial_config["refresh_interval"]
    end
  end
end
