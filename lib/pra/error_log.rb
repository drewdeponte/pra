require 'pra/config'
require 'date'

module Pra
  class ErrorLog
    def self.log(error)
      File.open(Pra::Config.error_log_path, 'a') do |f|
        f.puts("#{DateTime.now.iso8601} - #{error.message}")
        error.backtrace.each { |line| f.puts(line) }
      end
    end
  end
end
