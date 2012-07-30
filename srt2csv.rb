# -*- coding: utf-8 -*-
require 'csv'
require 'fileutils'
require 'find'
def srt2csv(file)
  arr = splitfile(file)
  file_with_bom
  write_to_file(arr)
end
def r_srt2csv
  input = File.expand_path $input
  output = File.expand_path $output 
  Find.find(input) do |file|
    next unless file =~ /ass$/i
    next if File.directory?(file)
    $inputfile = File.basename(file, 'srt') # $inputfile is filename. , with a dot
    $inputpath = File.dirname(file)
    $newpath = $inputpath.sub(input, output)
    puts "正在处理： #{file} \n"
    ass2csv(file)
  end
  ending_msg
end

r_srt2csv()
