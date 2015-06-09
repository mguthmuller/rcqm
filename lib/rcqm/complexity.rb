require_relative 'metric.rb'
require 'json'
require 'colorize'

# TODO : test

module Rcqm

  class Complexity < Rcqm::Metric

    def initialize(*args)
      super(*args)
      if !@options[:quiet]
        puts
        puts '*********************************************'.blue.bold
        puts '***************** Complexity ****************'.blue.bold
        puts '*********************************************'.blue.bold
      end
    end

    def check_file(filename)
      if !@options[:quiet]
        puts
        puts "*** Analyze file #{filename} ***".green
      end
      flog_res = `flog -abcm #{filename}`
      results = parse_flog_output(flog_res)
      print_complexity_scores(results) unless @options[:quiet]
      report_result(filename, results)
    end

    def parse_flog_output(output)
      res = {
        :total => 0,
        :per_method => []
      }
      output.lines do |line|
        next if line.strip.empty?
        splitted_line = line.split(' ')
        next if splitted_line[1].eql? 'flog/method'
        if splitted_line[1..2].join(' ').eql? 'flog total'
          res[:total] = splitted_line[0].gsub(/:/,'')
        else
          res[:per_method] << {:method => splitted_line[1], :complexity => splitted_line[0].gsub(/:/,'')}
        end
      end
      res
    end

    def report_result(filename, results)
      if File.exist?('reports/complexity.json')
        reports = JSON.parse(IO.read('reports/complexity.json'))
      else
        reports = {}
      end
      reports[filename] ||= []
      reports[filename] << {
        'Date' => Time.now,
        'Total' => results[:total],
        'Complexity per method' => results[:per_method] 
      }
      File.open('reports/complexity.json', 'w') do |fd|
        fd.puts(JSON.pretty_generate(reports))
      end
    end

    def print_complexity_scores(scores)
      puts "Complexity".rjust(10) + " | " + "Method name".ljust(50)
      puts '--------------------------------------------------------------------'
      scores[:per_method].each do |res|
        puts "#{res[:complexity]}".rjust(10) + " | " + "#{res[:method]}"
      end
      puts '--------------------------------------------------------------------'
      puts "#{scores[:total]}".rjust(10) + ' | ' + "Total"
    end
    
  end

end
