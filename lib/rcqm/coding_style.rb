require_relative 'metric.rb'
require 'json'

module Rcqm

  class CodingStyle < Rcqm::Metric

    def initialize(*args)
      super(*args)
      puts '\n************************************************'
      puts '******************* Coding style *****************'
      puts '************************************************'
    end

    def check_file(filename)
      puts "== Analyze file #{filename} =="
      config = (@options[:config].nil?) ? 'config/.rubocop.yml' : @options[:config]
      rubocop_res = `rubocop --format simple -c #{config} #{filename}`
      results = parse_rubocop_output(rubocop_res)
      print_offenses(results)
      report_result(filename, results)
    end

    def parse_rubocop_output(output)
      offenses = {
        :C => [],
        :E => [],
        :F => [],
        :W => []
      }
      output.lines do |line|
        next if line =~ /^==/
        break if line.strip.empty?
        splitted_line = line.split(' ')
        offense_level = splitted_line[0].gsub(/\:/,'')
        line_number = splitted_line[1].gsub(/\:/,'')
        column_number = splitted_line[2].gsub(/\:/,'')
        index_end = splitted_line.length
        msg = splitted_line[3..index_end-1].join(' ')
        case offense_level
        when 'C'
          offenses[:C] << "Line: #{line_number}, Column: #{column_number} - #{msg}"
        when 'E'
          offenses[:E] << "Line: #{line_number}, Column: #{column_number} - #{msg}"
        when 'F'
          offenses[:F] << "Line: #{line_number}, Column: #{column_number} - #{msg}"
        when 'W'
          offenses[:W] << "Line: #{line_number}, Column: #{column_number} - #{msg}"
        end
      end
      offenses
    end

    def print_offenses(results)

    end

    def report_result(filename, res)
     # Create dir 'reports' if it does not exist yet
      Dir.mkdir('reports', 0755) unless Dir.exist?('reports')
      
      # Store analysis results
      if File.exist?('reports/coding_style.json')
        reports = JSON.parse(IO.read('reports/coding_style.json'))
      else
        reports = {}
      end
      reports[filename] ||= []
      reports[filename] << {
        'Date' => Time.now,
        'Issues with convention' => (res[:C].empty?) ? nil : res[:C],
        'Errors' => (res[:E].empty?) ? nil : res[:E],
        'Fatal errors' => (res[:F].empty?) ? nil : res[:F],
        'Warnings' => (res[:W].empty?) ? nil : res[:W]
      }
      File.open('reports/coding_style.json', 'w') do |fd|
        fd.puts(JSON.pretty_generate(reports))
      end
    end
    
  end

end
