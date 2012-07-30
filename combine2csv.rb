# -*- coding: utf-8 -*-
require './lib/script2csv.rb'
require 'csv'
require 'fileutils'
require 'find'
$input = File.expand_path(ARGV[0])
$output = File.expand_path(ARGV[1])
def all_in_one($input, $output)
  all_dirs = []
  Find.find($input) do |d|
    if File.directory? d
      all_dirs << d
    end
  end
  finaldir = []
  all_dirs.each do |d2|
    if Dir.glob("#{d2}/*.srt").size == 2 # Dir.glob returns an array
      finaldir << d2
    end
  end
#  p finaldir
  finaldir.each do |d3|
    filelist = Dir.glob("#{d3}/*.srt") # return an array
    if filelist[0] =~ /chs/i
      zh_file, en_file = filelist[0], filelist[1]
    else
      zh_file, en_file = filelist[1], filelist[0]
    end
    filepath = File.dirname(File.expand_path(zh_file))
#    p filepath
    $newpath = filepath.sub("#{INPUT}", "#{OUTPUT}")
#    p $newfilepath
    $inputfile = File.basename(zh_file, 'srt')
    p "transforming: #{$inputfile} \n"
    combined_str = File.read(zh_file) + "\n" + File.read(en_file)
    file_with_bom
    write_to_file(generate_hash(combined_str))
  end
end

all_in_one($input, $output)
