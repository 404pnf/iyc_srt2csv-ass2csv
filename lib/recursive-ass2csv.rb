# -*- coding: utf-8 -*-
require 'csv'
require 'fileutils'
require 'find'

# usage:  script inputfile

# 将ass文件转为csv

INPUTDIR = ARGV[0]
#SUFFIX = /ass$/i
=begin
Find.find('source') do |file|
  next unless file =~ /ass$/i
  next if File.directory?(file)
  $inputfile = File.basename(file)
  $path = (File.expand_path(file)).split('/')
  $path.pop
end
=end
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
def r_ass2csv(dir)
  dir = dir.chomp('/') # de-slash
#  FileUtils.cp_r(dir, 'target')
  Find.find(dir) do |file|
    next unless file =~ /ass$/i
    next if File.directory?(file)
    $inputfile = File.basename(file)
    p $inputfile
    path = (File.expand_path(file)).split('/') # path now is absolute with root /, e.g /home/user/file.ass
    path.pop # remove filename
    path.shift # remove leading ""
    path = path.join('/')
    path = path.sub(/\A/, '/') # add root directory
    #p path
    $newpath = path.sub('source', 'target')
    #p $inputfile
    #p $newpath
    ass2csv(file)
  end
end
r_ass2csv(ARGV[0])
