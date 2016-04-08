module Rubycrap
  class Reporter

    attr_reader :crap_methods, :crap_methods_by_score

    def initialize(crap_methods)
      @crap_methods = crap_methods
      @crap_methods_by_score = crap_methods.sort_by { |k| -k[:crap_score] }
    end

    def html
      File.open("CRAP.html", 'w') { |file| file.write(build_html) }
    end

    def console
      crap_methods_by_score[0..10].each do |element|
        puts formated_result(element)
      end
    end

    private

    def build_html
      html = Array.new(0)
      html.push('<script   src="https://code.jquery.com/jquery-2.2.2.min.js"   integrity="sha256-36cp2Co+/62rEAAYHLmRCPIych47CvdM+uTBJwSzWjI="   crossorigin="anonymous"></script>')
      html.push('<script   src="https://cdn.datatables.net/1.10.11/js/jquery.dataTables.js" crossorigin="anonymous"></script>')
      html.push('<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css">')
      html.push('<script type="text/javascript">')
      html.push('  $(document).ready(function(){')
      html.push('    $(\'#myTable\').DataTable();')
      html.push('  });')
      html.push('</script>')
      html.push('<table id="myTable">')
      html.push('<thead>')
      html.push('  <tr>')
      html.push('    <th>methodname</th>')
      html.push('    <th>flog_score</th>')
      html.push('    <th>filepath</th>')
      html.push('    <th>startline</th>')
      html.push('    <th>method_coverage</th>')
      html.push('    <th>crap_score</th>')
      html.push('  </tr>')
      html.push('</thead>')
      html.push('<tbody>')
      html.push('')

      @crap_methods_by_score.each do |element|
        html.push('<tr>')
        html.push("  <td>#{element[:methodname]}</td>")
        html.push("  <td>#{element[:flog_score]}</td>")
        html.push("  <td>#{element[:filepath]}</td>")
        html.push("  <td>#{element[:startline]}</td>")
        html.push("  <td>#{element[:method_coverage]}</td>")
        html.push("  <td>#{element[:crap_score]}</td>")
        html.push('</tr>')
      end
      html.push('</tbody>')
      html.push('</table>')
      html
    end

    def formated_result(element)
      @crap_element = element
      "#{crap_score} | #{method_name} |  #{file_path}:#{start_line}"
    end

    def crap_score
      @crap_element[:crap_score].round.to_s.ljust(6)
    end

    def method_name
      @crap_element[:methodname].ljust(50)
    end

    def file_path
      @crap_element[:filepath]
    end

    def start_line
      @crap_element[:startline]
    end
  end
end
