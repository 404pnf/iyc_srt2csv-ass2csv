# -*- coding: utf-8 -*-
require 'find'
def split_srt(str)
  newstr = ''
  str = str.gsub(/\r/, "\n")
  str = str.gsub(/<[^>]+>/,'')
  str = str.gsub(/{[^}]+}/,'')
  str = str.gsub('\N','')
  arr = str.split(/\n[0-9]+\n/)
  arr.each do |i|
    i = i.gsub(/\n/, ' ')
    i = i.gsub(/  +/, ' ')
    i = i.slice(31,1000)
    # 删除这种垃圾 <font color=\"#ffff00\">
    # 删除这种垃圾{\fn微软雅黑\fs20}
    # delete charcaters '\N'
    newstr << "#{i}\n" 
    #    p i
  end
  return newstr
end
$input = File.expand_path(ARGV[0])
# $output = File.expand_path(ARGV[1])
def all_in_one(inputfolder)
  input = $input
  Find.find(input) do |file|
    next unless file =~ /.srt$/
    onlytext = split_srt(File.read(file))
    file_base_name = File.basename(file, '.srt')
    newfilename = file_base_name + '.txt'
    filepath = File.dirname(file)
    p "writing #{filepath}/#{newfilename}"
    File.open("#{filepath}/#{newfilename}", 'w') do |f|
      f.puts onlytext
    end 
  end
end

all_in_one($input)


s = '''
42
00:02:58,000 --> 00:03:02,000
{\fn微软雅黑\fs24}下一个，问题四

43
00:03:02,000 --> 00:03:04,000
{\fn微软雅黑\fs24}某恒星，等等等等…

44
00:03:04,000 --> 00:03:09,000
{\fn微软雅黑\fs24}这对计算会造成影响吗？为何？

45
00:03:09,000 --> 00:03:12,000
{\fn微软雅黑\fs24}这个题很重要
{\fn微软雅黑\fs24}这个题很重要

46


47

'''
#split_srt s

=begin
irb(main):379:0> s.split(/^[0-9]+$/).map {|i| i.gsub(/\n/, ' ').gsub(/  +/, ' ')}
=> [" ", " 00:02:51,000 --> 00:02:58,000 {\\fn微软雅黑\\fs24}这个题实际上要难得多 ", " 00:02:58,000 --> 00:03:02,000 {\\fn微软雅黑\\fs24}下一个，问题四 ", " 00:03:02,000 --> 00:03:04,000 {\\fn微软雅黑\\fs24}某恒星， 发撒旦 "]
irb(main):380:0> s.split(/^[0-9]+$/).map {|i| i.gsub(/\n/, ' ').gsub(/  +/, ' ')}
=> [" ", " 00:02:51,000 --> 00:02:58,000 {\\fn微软雅黑\\fs24}这个题实际上要难得多 ", " 00:02:58,000 --> 00:03:02,000 {\\fn微软雅黑\\fs24}下一个，问题四 ", " 00:03:02,000 --> 00:03:04,000 {\\fn微软雅黑\\fs24}某恒星， 发撒旦 "]
irb(main):381:0> s.split(/^[0-9]+$/).map {|i| i.gsub(/\n/, ' ').gsub(/  +/, ' ').slice(31,1000)}
=> [nil, "{\\fn微软雅黑\\fs24}这个题实际上要难得多 ", "{\\fn微软雅黑\\fs24}下一个，问题四 ", "{\\fn微软雅黑\\fs24}某恒星， 发撒旦 "]

s.split(/^[0-9]+$/).map do |i| 
i.gsub(/\n/, ' ')
.gsub(/  +/, ' ')
.slice(31,1000)
# 删除这种垃圾 <font color=\"#ffff00\">
.gsub(/<[^>]+>/,'')  
# 删除这种垃圾   {\fn微软雅黑\fs20}
.gsub(/{.+[^{]+}/,'') 
# delete charcaters '\N'
.gsub('\N','') 
end

=end
