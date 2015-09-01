require 'pra/config'

module Pra
  class Log
    def self.log(message)
      File.open(Pra::Config.log_path, 'a') do |f|
        f.puts("#{Time.now.iso8601} - #{message}")
      end
    end
  end
end
