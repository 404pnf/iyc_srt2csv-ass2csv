# -*- coding: utf-8 -*-
#require './lib/script2csv.rb'
#require './lib/transcript2csv.rb'
require './lib/newclass.rb'
#require 'csv'
#require 'fileutils'
#require 'find'
$input = File.expand_path(ARGV[0])
$output = File.expand_path(ARGV[1])
def srt2csv(file)
  arr = split_srt(File.read(file))
  arr_csv = srt_generate_hash(arr)
  file_with_bom
  write_to_file arr_csv
end
def r_srt2csv(input, output)
  input = File.expand_path $input
  output = File.expand_path $output 
  Find.find(input) do |file|
    next unless file =~ /srt$/i
    next if File.directory?(file)
    $inputfile = File.basename(file, 'srt') # $inputfile is filename. , with a dot
    inputpath = File.dirname(file)
    $newpath = inputpath.sub(input, output)
    puts "正在处理： #{file} \n"
    srt2csv(file)
  end
  ending_msg
end

r_srt2csv($input, $output)
