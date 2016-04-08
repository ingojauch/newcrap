require 'parser/current'
require 'flog_cli'
require 'json'
require 'builder'
require 'rubycrap/logging'
require 'rubycrap/coverage'
require 'rubycrap/crap'

module Rubycrap
  class Application
  
    def initialize(filename,mode)
      Rubycrap::logger.level = mode
      coverage = JSON.parse(File.open(filename, "r").read)
      @coverage_files = coverage["files"]
      @simplecov_information=[]
      @crap_methods=[]
    end

    def self.minfo(object)
      puts ">supports: #{(object.methods  - Object.methods).inspect}\n"
    end

    def hasharray_to_html( hashArray )
  # collect all hash keys, even if they don't appear in each hash:
      headers = hashArray.inject([]){|a,x| a |= x.keys ; a}  
  # use array union to find all unique headers/keys
      html = Builder::XmlMarkup.new(:indent => 2)
      html.table {
        html.tr { headers.each{|h| html.th(h)} }
        hashArray.each do |row|
          html.tr { row.values.each { |value| html.td(value) }}
        end
      }
      return html
    end

    def execute
      puts "total files: #{@coverage_files.count}"
      @coverage_files.each.with_index(1) do |file, index|
        Rubycrap::logger.debug("file nr. #{index}")
        @simplecov_information.concat(Rubycrap::Coverage.new(file).process_simplecov_file)
        @crap_methods.concat(Rubycrap::Crap.new(@simplecov_information,file).calculate_with_flog)
      end
      show_results
# buidler sucks
# it doesnt do thead and tbody
# and th: isnt accepted in datatables

# <script   src="https://code.jquery.com/jquery-2.2.2.min.js"   integrity="sha256-36cp2Co+/62rEAAYHLmRCPIych47CvdM+uTBJwSzWjI="   crossorigin="anonymous"></script>
# <script   src="https://cdn.datatables.net/1.10.11/js/jquery.dataTables.js" crossorigin="anonymous"></script>
# <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css">
# <script type="text/javascript">
#   $(document).ready(function(){
#     $('#myTable').DataTable();
#   });
# </script>

# <table id="myTable">

    end

    def sort_crap
      @crap_methods.sort_by { |k| -k[:crap_score] }
    end

    def show_results
      puts "\nRESULTS"
      sort_crap.each do |element|
        puts "#{element[:crap_score].round}".ljust(6) + "#{element[:methodname]}  ---> #{element[:filepath]}:#{element[:startline]}"
      end
      File.open("CRAP.html", 'w') { |file| file.write(hasharray_to_html(sort_crap)) }
      puts "THE END"
    end
  end
end
