require_relative 'metric.rb'
require 'json'

# TODO : test

module Rcqm

  class Statistics < Rcqm::Metric

    def initialize(*args)
      super(*args)
      puts
      puts '*********************************************'.blue
      puts '***************** Statistics ****************'.blue
      puts '*********************************************'.blue
      puts
    end

    def check_file(filename)
      puts
      puts "*** Analyze file #{filename} ***".green
      @lines = File.readlines(filename)
      res = {
        :total => @lines.length,
        :empty_lines => 0,
        :comments => 0,
        :locs => 0,
        :modules => 0,
        :classes => 0,
        :methods => 0,
        :requires => 0
      }
      @lines.each do |line|
        if (line.strip).empty? then res[:empty_lines] += 1
        elsif line.strip =~ /^#/ then res[:comments] += 1
        else
          res[:locs] += 1
          if line.strip =~ /^module/ then res[:modules] += 1
          elsif line.strip =~ /^class/ then res[:classes] += 1
          elsif line.strip =~ /^require/ then res[:requires] += 1
          elsif line.strip =~ /^def/ then res[:methods] += 1
          end
        end
      end
      print_statistics(res)
      report_result(filename, res)
    end

    def print_statistics(res)
      puts "Total lines: #{res[:total]}"
      puts "Empty lines: #{res[:empty_lines]}"
      puts "Commented lines: #{res[:comments]}"
      puts "Lines of code: #{res[:locs]}"
      puts "Modules: #{res[:modules]}"
      puts "Classes: #{res[:classes]}"
      puts "Methods: #{res[:methods]}"
      puts "Requires: #{res[:requires]}"
    end

    def report_result(filename, res)
      # Create dir 'reports' if it does not exist yet
      Dir.mkdir('reports', 0755) unless Dir.exist?('reports')
      
      # Store analysis results
      if File.exist?('reports/statistics.json')
        reports = JSON.parse(IO.read('reports/statistics.json'))
      else
        reports = {}
      end
      reports[filename] ||= []
      reports[filename] << {
        'Date' => Time.now,
        'Total lines' => res[:total],
        'Empty lines' => res[:empty_lines],
        'Commented lines' => res[:comments],
        'Lines of code' => res[:locs],
        'Modules' => res[:modules],
        'Classes' => res[:classes],
        'Methods' => res[:methods],
        'Requires' => res[:requires]
      }
      File.open('reports/statistics.json', 'w') do |fd|
        fd.puts(JSON.pretty_generate(reports))
      end
    end
    
  end

end
