module Rubycrap
  class Reporter

    attr_reader :crap_methods, :crap_methods_by_score

    def initialize(crap_methods)
      @crap_methods = crap_methods
      @crap_methods_by_score = crap_methods.sort_by { |k| -k[:crap_score] }
    end

    def html
      # buidler sucks
      # it doesnt do thead and tbody
      # and th: isnt accepted in datatables
      # <script   src="https://code.jquery.com/jquery-2.2.2.min.js"
      # integrity="sha256-36cp2Co+/62rEAAYHLmRCPIych47CvdM+uTBJwSzWjI="
      # crossorigin="anonymous"></script>
      # <script
      # src="https://cdn.datatables.net/1.10.11/js/jquery.dataTables.js"
      # crossorigin="anonymous"></script>
      # <link rel="stylesheet" type="text/css"
      # href="https://cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css">
      # <script type="text/javascript">
      # $(document).ready(function(){
      # $('#myTable').DataTable();
      # });
      # </script>
      # <table id="myTable">
      File.open("CRAP.html", 'w') { |file| file.write(build_html) }
    end

    def console
      crap_methods_by_score.each do |element|
        puts formated_result(element)
      end
    end

    private

    def build_html
      headers = @crap_methods_by_score.inject([]){|a,x| a |= x.keys ; a}
      html = Builder::XmlMarkup.new(:indent => 2)
      html.table {
        html.tr { headers.each{|h| html.th(h)} }
        @crap_methods_by_score.each do |row|
          html.tr { row.values.each { |value| html.td(value) }}
        end
      }
      html
    end

    def formated_result(element)
      @crap_element = element
      "#{crap_score}".ljust(6) + "#{method_name}  ---> #{file_path}:#{start_line}"
    end

    def crap_score
      @crap_element[:crap_score].round
    end

    def method_name
      @crap_element[:methodname]
    end

    def file_path
      @crap_element[:filepath]
    end

    def start_line
      @crap_element[:startline]
    end
  end
end
