require 'parser/current'
require 'flog_cli'
require 'json'
require 'builder'
require 'logger'

module Rubycrap
class Application 
	@simplecov_information=[]
	@crap_methods=[]
	def self.minfo(object)
	  puts ">supports: #{(object.methods  - Object.methods).inspect}\n"
	end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
	#
	# => reads the sourcefile with an ast parser to get all the methods, then calculate the method coverage
	#
	def self.process_simplecov_file(file)
	  #get filename with its coverage information
	  filename = file["filename"]
    logger.debug(filename)
	  parse_method_coverage(file,filename)
	end

	def self.parse_method_coverage(file,filename)
	  ast = Parser::CurrentRuby.parse(File.open(filename, "r").read)
	  recursive_search_ast(file,ast)
	end

	def self.calculate_method_coverage(file,startline,lastline)
	  # first we get the coverage lines from simplecov
	  # start position -1 and number of total lines (-1 if you dont want the end)
	  total_lines = lastline-startline
    logger.debug("startline #{startline}")
    logger.debug("latline #{lastline}")
	  coveragelinestotal = file["coverage"]
	  	 
    logger.debug( "total_lines #{total_lines}")
	  coveragelines = coveragelinestotal.slice(startline-1,total_lines)
    logger.debug("coveragelines: #{coveragelines}")
	  covered_lines = 0
	  coveragelines.each do |line|
	    if !(line.to_s.eql? "0" or line.to_s.eql? "")
	      covered_lines = covered_lines + 1
	    end
	  end
	  method_coverage = covered_lines.to_f / total_lines.to_f
    logger.debug("method_coverage: #{method_coverage}")
	  return method_coverage
	end

	def self.recursive_search_ast(file,ast)
		begin
			ast.children.each do |child|
				if child.class.to_s == "Parser::AST::Node"
				  if (child.type.to_s == "def" or child.type.to_s == "defs")

				    methodname = child.children[0].to_s
				    startline = child.loc.line
				    lastline = child.loc.last_line
				    logger.debug("\nmethodname: #{methodname}")
				    method_coverage = calculate_method_coverage(file,startline,lastline)

				    @simplecov_information << {:name => methodname, :coverage => method_coverage , :startline => startline, :lastline => lastline}
				  else
				    recursive_search_ast(file,child)
				  end
				end
			end
		rescue
			# maybe empty source code
		end
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
      logger.debug("flogger absolute_filename: #{file["filename"]}")
			flogger.each_by_score nil do |class_method, score, call_list|
				startline = flogger.method_locations[class_method].split(":")[1]
				absolute_filename = flogger.method_locations[class_method].split(":")[0]
        logger.debug("flogger startline: #{startline}")
				#match simplecov line with startine form floc
				element = @simplecov_information.detect {|f| f[:startline] == startline.to_i }
				if element.to_s == ""
          logger.debug("no match with simplecov for logger class_method: #{class_method} startline: #{startline} ")
				else
          logger.debug("flogger class_method: #{class_method} simplecov: #{element}")
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
    logger.level = mode
    coverage = JSON.parse(File.open(coveragefile, "r").read)

		# file = coverage["files"].first
		#
		# => get all the source filenames from the coverage file
		#
		puts "total files: #{coverage["files"].count}"
		coverage["files"].each.with_index(1) do |file, index|
      logger.debug("file nr. #{index}")
		  process_simplecov_file(file)
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
