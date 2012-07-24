# -*- coding: utf-8 -*-
require 'csv'
require 'fileutils'
require 'find'

# usage:  script inputfile

# excel不认识utf-8的csv文件，必须加不合规范的BOM头
# 参考： http://stackoverflow.com/questions/155097/microsoft-excel-mangles-diacritics-in-csv-files


# 所有srt应该放在 source 文件夹下
# 输出的文件夹是 target

INPUTDIR = ARGV[0]
SUFFIX = /srt/i
def splitfile(file)
  str = File.read(file)
  str = str.encode('utf-8', 'utf-16')
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
def r_srt2csv(dir)
  dir = dir.chomp('/') # de-slash
  Find.find(dir) do |file|
    next unless file =~ /srt$/i
    next if File.directory?(file)
    $inputfile = File.basename(file)
    p $inputfile
    path = (File.expand_path(file)).split('/') # path now is absolute with root /, e.g /home/user/file.ass
    path.pop #remove filename
    path.shift #remove leading""
    path=path.join('/')
    $newpath=path.sub(/\A/,'/') #add root directory '/'
    #ppath
    #pfile
    srt2csv(file)
  end
end
r_srt2csv(ARGV[0])
