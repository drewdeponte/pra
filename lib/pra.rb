require "pra/version"

module Pra
  def self.config
    @config ||= Pra::Config.load_config
  end
end
