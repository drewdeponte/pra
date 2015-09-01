require 'pra/config'
require 'date'

module Pra
  class Log
    def self.log(message)
      File.open(Pra::Config.log_path, 'a') do |f|
        f.puts("#{DateTime.now.iso8601} - #{message}")
      end
    end
  end
end
