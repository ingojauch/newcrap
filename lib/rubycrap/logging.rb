require 'logger'

module Rubycrap
  def logger
    Logging.logger
  end
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
