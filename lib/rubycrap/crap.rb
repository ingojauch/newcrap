require 'flog_cli'
require 'rubycrap/logging'

module Rubycrap
  class Crap
    attr_reader :simplecov_information, :file
    def initialize(simplecov_information,file)
      @simplecov_information = simplecov_information
      @file = file
      @simplecov_information = []
    end

    def crap(complexity,coverage)
      complexity ** 2 * (1 - coverage) ** 3 + complexity
    end

    def calculate_with_flog
      begin
        flog_file(file["filename"])
        @flogger.each_by_score nil do |class_method, score, call_list|
          Rubycrap::logger.debug("flogger startline: #{startline}")
          element = simplecov_information.detect {|f| f[:startline] == startline.to_i}
          if element.to_s == ""
            Rubycrap::logger.debug("no match with simplecov for flogger class_method: #{class_method} startline: #{startline} ")
          else
            Rubycrap::logger.debug("flogger class_method: #{class_method} simplecov: #{element}")
            test_coverage = element[:coverage]
            @crap_methods << {:methodname => class_method, 
                             :flog_score => score ,
                             :filepath => absolute_filename, 
                             :startline => startline, 
                             :method_coverage => test_coverage, 
                             :crap_score => crap(score,test_coverage)}
          end
        end
        @crap_methods
      rescue
        #Rubycrap::logger.debug("something went wrong with flog")
        @crap_methods
      end
    end

    private
    
    def flog_file(filename)
      FlogCLI.load_plugins
      options = FlogCLI.parse_options "-qma"
      @flogger = FlogCLI.new options
      @flogger.flog filename
      Rubycrap::logger.debug("flogger absolute_filename: #{filename}")
    end

    def startline
      @flogger.method_locations[class_method].split(":")[1]
    end

    def absolute_filename
      @flogger.method_locations[class_method].split(":")[0]
    end
  end
end
