require 'flog_cli'
require 'rubycrap/logging'

module Rubycrap
  class Crap
    attr_reader :simplecov_information
    def initialize(simplecov_information)
      @simplecov_information = simplecov_information
    end

    def crap(complexity,coverage)
      complexity ** 2 * (1 - coverage) ** 3 + complexity
    end

    def calculate_with_flog
      begin
        FlogCLI.load_plugins
        options = FlogCLI.parse_options "-qma"
        flogger = FlogCLI.new options
        flogger.flog file["filename"]
        logger.debug("flogger absolute_filename: #{file["filename"]}")
        flogger.each_by_score nil do |class_method, score, call_list|
          startline = flogger.method_locations[class_method].split(":")[1]
          absolute_filename = flogger.method_locations[class_method].split(":")[0]
          logger.debug("flogger startline: #{startline}")
          element = simplecov_information.detect {|f| f[:startline] == startline.to_i}
          if element.to_s == ""
            logger.debug("no match with simplecov for logger class_method: #{class_method} startline: #{startline} ")
          else
            logger.debug("flogger class_method: #{class_method} simplecov: #{element}")
            test_coverage = element[:coverage]
            crap_methods << {:methodname => class_method, 
                             :flog_score => score ,
                             :filepath => absolute_filename, 
                             :startline => startline, 
                             :method_coverage => test_coverage, 
                             :crap_score => crap(score,test_coverage)}
          end
        end
      rescue
        logger.debug("something went wrong with flog")
      end
    end
  end
end
