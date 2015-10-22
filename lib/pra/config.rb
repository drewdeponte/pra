require 'json'

module Pra
  class Config
    def initialize(initial_config = {})
      @initial_config = initial_config
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
      return File.join(self.users_home_directory, '.pra.json')
    end

    def self.error_log_path
      return File.join(self.users_home_directory, '.pra.errors.log')
    end

    def self.log_path
      return File.join(self.users_home_directory, '.pra.log')
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
  end
end
