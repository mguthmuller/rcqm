require_relative 'metric.rb'
require 'json'

# TODO : test

module Rcqm

  class Tags < Rcqm::Metric

    def initialize(*args)
      super(*args)
      puts "*************************************************"
      puts "***************** Tags matching *****************"
      puts "*************************************************"
    end
    
    def get_regexp
      if @options[:tags].nil?
        return "TODO|FIXME"
      else
        pattern = ""
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
      puts "== Analyze file #{filename} =="
      lines = []
      line_num = 0
      pattern = get_regexp
      File.open(filename, 'r') do |file|
        file.each_line do |line|
          line_num += 1
          lines << [filename, line_num, line] if line =~ /#{pattern}/i
        end
      end
      report_result(filename, lines.length)
      print_tags(lines)
      return lines
    end

    def print_tags(res)
      res.map do |filename, line_num, line|
        puts "#{filename}(#{line_num}): #{line.strip}"
      end
    end

    def report_result(filename,total)
      # Create dir 'reports' if it does not exist yet
      if !(Dir.exist?("reports")) then Dir.mkdir("reports", 0755) end

      new_result = Result.new(Time.now, total)
      
      File.open("reports/tags.json", 'a+') do |file|
        if File.size?(file) == nil # Empty file
          new_entry = {filename => [{'date' => Time.now, 'total' => total}]}.to_json
          file << new_entry
        else
          json_res = JSON.parse(file.read)
          puts  json_res[filename].to_a
          json_res[filename].to_a << {'date' => Time.now, 'total' => total}
          JSON.dump(json_res, file)
        end
      end
    end
      
  end
  
end
