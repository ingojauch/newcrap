require 'rubycrap/logging'

module Rubycritic
  class Coverage

    attr_reader :file,:filename

    def initialize(file)
      @file = file
      @filename = file["filename"]
    end

    def process_simplecov_file
      logger.debug(filename)
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
            logger.debug("\nmethodname: #{methodname}")
            method_coverage = calculate_method_coverage(file,startline,lastline)
            simplecov_information << {:name => methodname, 
                                      :coverage => method_coverage , 
                                      :startline => startline, 
                                      :lastline => lastline}
          else
            search_methods(child)
          end
        end
      rescue
        logger.debug("Coverage#search_method - empty source code")
      end
      simplecov_information
    end

    private
    def method?(child)
      child.class.to_s == "Parser::AST::Node" && 
        (child.type.to_s == "def" or child.type.to_s == "defs")
    end

  end
end
