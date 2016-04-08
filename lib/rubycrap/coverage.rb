require 'rubycrap/logging'

module Rubycrap
  class Coverage

    attr_reader :file,:filename, :coverage

    def initialize(file)
      @file = file
      @filename = file["filename"]
      @coverage = file["coverage"]
    end

    def process_simplecov_file
      Rubycrap::logger.debug(filename)
      ast = parse_method_coverage
      search_methods(ast)
    end

    def parse_method_coverage
       Parser::CurrentRuby.parse(File.open(filename, "r").read)
    end

    def search_methods(ast)
      simplecov_information = []
      begin
        ast.children.each do |child|
          if(method?(child))
            methodname = child.children[0].to_s
            startline = child.loc.line
            lastline = child.loc.last_line
            Rubycrap::logger.debug("\nmethodname: #{methodname}")
            method_coverage = calculate_method_coverage(startline,lastline)
            simplecov_information << {:name => methodname, 
                                      :coverage => method_coverage , 
                                      :startline => startline, 
                                      :lastline => lastline}
          else
            search_methods(child)
          end
        end
      rescue
        #Rubycrap::logger.debug("Coverage#search_method - empty source code")
      end
      simplecov_information
    end
    
    def calculate_method_coverage(startline,lastline)
      total_lines = lastline-startline
      Rubycrap::logger.debug("Startline #{startline} | Lastline #{lastline} | Total_lines #{total_lines}")
      coveragelinestotal = coverage
      coveragelines = coveragelinestotal.slice(startline-1,total_lines)
      Rubycrap::logger.debug("coveragelines: #{coveragelines}")
      covered_lines = 0
      coveragelines.each do |line|
        if coverage?(line)
          covered_lines += 1
        end
      end
      method_coverage = covered_lines.to_f / total_lines.to_f
      Rubycrap::logger.debug("method_coverage: #{method_coverage}")
      method_coverage
    end

    private
    def method?(child)
      child.class.to_s == "Parser::AST::Node" && 
        (child.type.to_s == "def" or child.type.to_s == "defs")
    end

    def coverage?(line)
      !(line.to_s.eql? "0" or line.to_s.eql? "")
    end

  end
end
