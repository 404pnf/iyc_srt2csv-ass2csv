# -*- coding: utf-8 -*-
require 'csv'
require 'fileutils'
require 'find'

# usage:  script inputfile

# 将单个ass文件转为csv

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
