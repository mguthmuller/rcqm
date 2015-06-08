require_relative 'metric.rb'
require 'json'
require 'colorize'

module Rcqm

  class Documentation < Rcqm::Metric

    def initialize(*args)
      super(*args)
      puts 
      puts '*************************************************'.bold.blue
      puts '*************** Documentation  rates ************'.bold.blue
      puts '*************************************************'.bold.blue
    end
    
    def check_file(filename)
      puts
      puts "*** Analyze file #{filename} ***".green
      pwd = Dir.pwd
      Dir.chdir(File.dirname(filename))
      inch_res = `inch #{File.basename(filename)}`
      Dir.chdir(pwd)
      results = parse_inch_output(uncolorize(inch_res))
      print_documentation_rates(results)
      report_result(filename, results)
    end

    def parse_inch_output(output)
      grades = {
        :A => [],
        :B => [],
        :C => [],
        :U => []
      }
      output.lines do |line|
        next if line.strip.empty?
        break if  (line =~ /^Nothing to suggest/) ||
                  (line =~ /^You might want to look at these files/)
        splitted_line = line.split(' ')
        case splitted_line[1]
        when 'A'
          grades[:A] << splitted_line[3]
        when 'B'
          grades[:B] << splitted_line[3]
        when 'C'
          grades[:C] << splitted_line[3]
        when 'U'
          grades[:U] << splitted_line[3]
        end
      end
      grades
    end

    def report_result(filename, res)
      # Create dir 'reports' if it does not exist yet
      Dir.mkdir('reports', 0755)  unless Dir.exist?('reports')
      
      # Store analysis results
      if File.exist?('reports/documentation.json')
        reports = JSON.parse(IO.read('reports/documentation.json'))
      else
        reports = {}
      end
      reports[filename] ||= []
      reports[filename] << {
        'Date' => Time.now,
        'Good documentation' => (res[:A].empty?) ? nil : res[:A],
        'Could be improved documentation' => (res[:B].empty?) ? nil : res[:B],
        'Need work documentation' => (res[:C].empty?) ? nil : res[:C],
        'Undocumented' => (res[:U].empty?) ? nil : res[:U]
      }
      File.open('reports/documentation.json', 'w') do |fd|
        fd.puts(JSON.pretty_generate(reports))
      end
    end

    def print_documentation_rates(res)
      unless res[:A].empty?
        puts '# Good documentation:'.red
        res[:A].each do |item|
          puts "  - #{item}" 
        end
      end
      unless res[:B].empty?
        puts '# Properly documented, but could be improved:'.red
        res[:B].each do |item|
          puts "  - #{item}" 
        end
      end
      unless res[:C].empty?
        puts '# Need work:'.red
        res[:C].each do |item|
          puts "  - #{item}" 
        end
      end
      unless res[:U].empty?
        puts '# Undocumented:'.red 
        res[:U].each do |item|
          puts "  - #{item}" 
        end
      end
    end
    
  end
  
end
