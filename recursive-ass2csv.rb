# -*- coding: utf-8 -*-
require 'csv'
require 'fileutils'
require 'find'

# usage:  script 
# 使用说明

# source目录的ass字母文件输出到同样目录结构的target目录
# 并转换为流氓微软的excel产品可直接读取的带有BOM的UTF-8编码的csv文件

def ass2csv_help
  if ARGV.length != 0
    puts "usage: ruby scriptname.rb"
    puts "put all ass files in a dir called 'source'"
    puts "a folder named 'target' would be generated with the expected results"
    puts "put this script in the same folder where 'source' and 'target' reside"
    puts "type ruby scriptname.rb"
    puts "have fun"
  end
end
def splitfile(file)
  str = File.read(file)
  str = str.encode('utf-8', 'utf-16')
  str = str.gsub(/\r/,"\n")
  str = str.gsub(/\n\n+/,"\n")
  arr = str.split(/\n/)
  arr = arr.reject {|i|  !(i =~ /^Dialogue/) }
  arr
end
def file_with_bom
#  Dir.mkdir('srt_csv') unless File.exist?('srt_csv')
  FileUtils.mkdir_p("#{$newpath}") unless File.exist?("#{$newpath}")
  File.open("#{$newpath}/#{$inputfile}.csv", 'w')do |f|
    f.puts  "\uFEFF"
  end
end
def write_to_file(arr)
  # 悲剧，ruby的csv默认就是不quote值，浪费了半个小时才找到:force_quote用法
  # http://stackoverflow.com/questions/5831366/quote-all-fields-in-csv-output
  CSV.open("#{$newpath}/#{$inputfile}.csv", 'a', {:force_quotes=>true}) do |csv| # append mode
    arr.each do |sentence| 
      sentence = sentence.gsub(/{[^}]+}/, '') # 有了它极大简化后面正则匹配
      sentence = sentence.sub(/^Dialogue..*,,/, '')
      tuple= sentence.split('\\N')
      zh = tuple[0]
      en = tuple[1]
      csv << [zh,en]
    end
  end
end
# 假设每行在去掉了所有{}和它中间的东西后都是这样的
# sentence = "Dialogue: 0,0:06:02.82,0:06:03.84,*Default,NTP,0000,0000,0000,,无一放过\\Nand anybody they found."
def ass2csv(file)
  arr = splitfile(file)
  file_with_bom
  write_to_file(arr)
end
def r_ass2csv
  ass2csv_help
#  dir = dir.chomp('/') # de-slash
  dir = 'source'
  Find.find(dir) do |file|
    next unless file =~ /ass$/i
    next if File.directory?(file)
    $inputfile = File.basename(file)
    path = (File.expand_path(file)).split('/') # path now is absolute with root /, e.g /home/user/file.ass
    path.pop # remove filename
    path.shift # remove leading ""
    path = path.join('/')
    path = path.sub(/\A/, '/') # add root directory
    $newpath = path.sub('source', 'target')
    puts "正在处理： #{file}"
    puts ""
    ass2csv(file) # defined in lib/recursive-ass2csv.rb
  end
  puts "========================================="
  puts "da di di da da"
  puts ''
  puts "都转好了，请查看当前目录下的target目录。"
  puts ''
  puts '========================================='
end
r_ass2csv()
