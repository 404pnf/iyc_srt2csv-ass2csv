# -*- coding: utf-8 -*-
require 'csv'
require 'fileutils'
require 'find'

# must run with ruby 1.9.x

# usage:  ruby script.rb
# 默认输入文件夹是 source 输出文件夹是 target

# excel不认识utf-8的csv文件，必须加不合规范的BOM头
# 参考： http://stackoverflow.com/questions/155097/microsoft-excel-mangles-diacritics-in-csv-files

def splitfile(file)
  str = File.read(file)
  str = str.encode('utf-8', 'utf-16le') # need to be specific utf-16le for mac osx compatability
  str = str.gsub(/\r/,"\n")
  str = str.gsub(/\n\n+/,"\n")
  arr = str.split(/^[0-9]+$/)
  arr.shift # 第一行是个空的
  arr
end
def file_with_bom
  Dir.mkdir("#{$newpath}") unless File.exist?("#{$newpath}")
  File.open("#{$newpath}/#{$inputfile}.csv", 'w')do |f|
    f.puts  "\uFEFF" # 因为流氓微软的存在
  end
end
def write_to_file(arr)
  # 悲剧，ruby的csv默认就是不quote值，浪费了半个小时才找到:force_quote用法
  # http://stackoverflow.com/questions/5831366/quote-all-fields-in-csv-output
  CSV.open("#{$newpath}/#{$inputfile}.csv", 'a', {:force_quotes=>true}) do |csv|
    arr.each do |row| # append mode
      zh = row.split(/\n/)[2]
      en = row.split(/\n/)[3]
      csv << [zh, en]
    end
  end
end
def srt2csv(file)
  arr = splitfile(file)
  file_with_bom
  write_to_file(arr)
end
def r_srt2csv
  dir = 'source'
  Find.find(dir) do |file|
    next unless file =~ /srt$/i
    next if File.directory?(file)
    $inputfile = File.basename(file)
    path = (File.expand_path(file)).split('/') # path now is absolute with root /, e.g /home/user/file.ass
    path.pop #remove filename
    path=path.join('/')
    $newpath = path.sub('source', 'target')
    puts "正在处理： #{$inputfile}"
    srt2csv(file)
  end
  puts "========================================="
  puts "da di di da da"
  puts ''
  puts "都转好了，请查看当前目录下的target目录。"
  puts ''
  puts '========================================='
end
r_srt2csv()
