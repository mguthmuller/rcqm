require_relative 'metric.rb'
require 'json'

# TODO : test

module Rcqm

  class Tags < Rcqm::Metric

    def initialize(*args)
      super(*args)
      puts 
      puts '*************************************************'.blue.bold
      puts '***************** Tags matching *****************'.blue.bold
      puts "*************************************************".blue.bold
      puts
    end
    
    def define_regexp
      if @options[:tags].nil?
        return 'TODO|FIXME'
      else
        pattern = ''
        tags_names = @options[:tags].split(',')
        tags_names.each do |tag_name|
          if pattern.empty?
            pattern << "#{tag_name}"
          else
            pattern << "|#{tag_name}"
          end
        end
        return pattern
      end
    end
    
    def check_file(filename)
      puts
      puts "*** Analyze file #{filename} ***".magenta
      lines = []
      line_num = 0
      pattern = define_regexp
      File.open(filename, 'r') do |file|
        file.each_line do |line|
          line_num += 1
          lines << [filename, line_num, line] if line =~ /#{pattern}/i
        end
      end
      report_result(filename, lines)
      print_tags(lines)
      lines
    end

    def print_tags(res)
      res.each do |filename, line_num, line|
        puts "#{filename}(#{line_num}): #{line.strip}"
      end
    end

    def format_result(res)
      return nil if res.empty?
      result = []
      res.each do |filename, line_num, line|
        result << "#{filename}(#{line_num}): #{line.strip}"
      end
      result
    end

    def report_result(filename,res)
      # Create dir 'reports' if it does not exist yet
      Dir.mkdir('reports', 0755) unless Dir.exist?('reports') 
      
      # Store analysis results
      if File.exist?('reports/tags.json')
        reports = JSON.parse(IO.read('reports/tags.json'))
      else
        reports = {}
      end
      reports[filename] ||= []
      reports[filename] << {
        'Date' => Time.now,
        'Total' => res.length,
        'Output' => format_result(res)
      }
      File.open('reports/tags.json', 'w') do |fd|
        fd.puts(JSON.pretty_generate(reports))
      end
    end
      
  end
  
end
