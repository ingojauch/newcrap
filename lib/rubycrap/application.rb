require 'parser/current'
require 'flog_cli'
require 'json'
require 'builder'
require 'rubycrap/logging'
require 'rubycrap/coverage'
require 'rubycrap/crap'
require 'rubycrap/reporter'

module Rubycrap
  class Application
  
    def initialize(filename,mode)
      Rubycrap::logger.level = mode
      coverage = JSON.parse(File.open(filename, "r").read)
      @coverage_files = coverage["files"]
    end

    def self.minfo(object)
      puts ">supports: #{(object.methods  - Object.methods).inspect}\n"
    end

    def execute
      @crap_methods = []
      puts "total files: #{@coverage_files.count}"
      @coverage_files.each.with_index(1) do |file, index|
        Rubycrap::logger.debug("file nr. #{index}")
        simplecov_information = Rubycrap::Coverage.new(file).process_simplecov_file
        @crap_methods.concat(Rubycrap::Crap.new(simplecov_information,file).calculate_with_flog)
      end
      show_results
    end

    def show_results
      reporter = Rubycrap::Reporter.new(@crap_methods)
      puts "\nRESULTS"
      reporter.console
      reporter.html
      puts "THE END"
    end
  end
end
