require_relative 'metric.rb'
require 'json'

# TODO : test

module Rcqm

  class Statistics < Rcqm::Metric

    def initialize(*args)
      super(*args)
      if !@options[:quiet]
        puts
        puts '*********************************************'.blue.bold
        puts '***************** Statistics ****************'.blue.bold
        puts '*********************************************'.blue.bold
      end
    end

    def check_file(filename)
      if !@options[:quiet]
        puts
        puts "*** Analyze file #{filename} ***".green
      end
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
      print_statistics(res) unless @options[:quiet]
      report_result(filename, res)
    end

    def print_statistics(res)
      puts "Total lines:".red + " #{res[:total]}"
      puts "Empty lines:".red + " #{res[:empty_lines]}"
      puts "Commented lines:".red + " #{res[:comments]}"
      puts "Lines of code:".red + " #{res[:locs]}"
      puts "Modules:".red + " #{res[:modules]}"
      puts "Classes:".red + " #{res[:classes]}"
      puts "Methods:".red + " #{res[:methods]}"
      puts "Requires:".red + " #{res[:requires]}"
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
