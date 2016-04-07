require 'parser/current'
require 'flog_cli'
require 'json'
require 'builder'
require 'rubycrap/logging'
require 'rubycrap/coverage'

module Rubycrap
  class Application
    @simplecov_information=[]
    @crap_methods=[]

    def self.minfo(object)
      puts ">supports: #{(object.methods  - Object.methods).inspect}\n"
    end

    def self.crap(score,coverage)
#    CRAP(m) = comp(m)^2 * (1 � cov(m)/100)^3 + comp(m)
      comp = score
      cov = coverage
      comp ** 2 * (1 - cov) ** 3 + comp
    end

    def self.calcualte_crap_from_flog(file)
      begin
        FlogCLI.load_plugins
        options = FlogCLI.parse_options "-qma"
        flogger = FlogCLI.new options

        flogger.flog file["filename"]
        Rubycrap::logger.debug("flogger absolute_filename: #{file["filename"]}")
        flogger.each_by_score nil do |class_method, score, call_list|
          startline = flogger.method_locations[class_method].split(":")[1]
          absolute_filename = flogger.method_locations[class_method].split(":")[0]
          Rubycrap::logger.debug("flogger startline: #{startline}")
#match simplecov line with startine form floc
          element = @simplecov_information.detect {|f| f[:startline] == startline.to_i }
          if element.to_s == ""
            Rubycrap::logger.debug("no match with simplecov for logger class_method: #{class_method} startline: #{startline} ")
          else
            Rubycrap::logger.debug("flogger class_method: #{class_method} simplecov: #{element}")
            test_coverage = element[:coverage]
            @crap_methods << {:methodname => class_method, :flog_score => score , :filepath => absolute_filename, :startline => startline, :method_coverage => test_coverage, :crap_score => crap(score,test_coverage)}
          end
        end
      rescue
        # something went wrong with flog
      end
    end

	def self.hasharray_to_html( hashArray )
	  # collect all hash keys, even if they don't appear in each hash:
	  headers = hashArray.inject([]){|a,x| a |= x.keys ; a}  # use array union to find all unique headers/keys                              

	  html = Builder::XmlMarkup.new(:indent => 2)
	  html.table {
	    html.tr { headers.each{|h| html.th(h)} }
	    hashArray.each do |row|
	      html.tr { row.values.each { |value| html.td(value) }}
	    end
	  }
	  return html
	end

  def self.run(coveragefile,mode)
    Rubycrap::logger.level = mode
    coverage = JSON.parse(File.open(coveragefile, "r").read)
    puts "total files: #{coverage["files"].count}"
    coverage["files"].each.with_index(1) do |file, index|
      Rubycrap::logger.debug("file nr. #{index}")
      @simplecov_information.concat(Rubycrap::Coverage.new(file).process_simplecov_file)
      calcualte_crap_from_flog(file)
    end

    @sorted = @crap_methods.sort_by { |k| -k[:crap_score] }

    puts "\nRESULTS"
    @sorted.each do |element|
      puts "#{element[:crap_score].round}".ljust(6) + "#{element[:methodname]}  ---> #{element[:filepath]}:#{element[:startline]}"
    end

		#
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

    File.open("CRAP.html", 'w') { |file| file.write(hasharray_to_html(@sorted)) }
    puts "THE END"
  end

end
end
