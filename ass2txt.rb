# -*- coding: utf-8 -*-
require 'find'

# usage: script.rb inputfolder
# generate 2 text files from one ass file, one for zh, one for en

def get_ass_text str
  arr = str.split(/^Dialogue:/).map do |i| 
    i = i.slice(54,1000)
    #    p i
  end
  arr = arr.reject {|i| i == nil}
  arr = arr.map do |i|
    # i = i.gsub(/<[^>]+>/,'')  # 删除这种垃圾 <font color=\"#ffff00\">
    i = i.gsub(/{.+[^{]+}/,'')  # 删除这种垃圾   {\fn微软雅黑\fs20}
    i = i.gsub(/\r/,'\n')  # no newline needed
    i = i.gsub(/\n/,'')  # no newline needed
    #    i = i.strip
    #   p i
  end
  arr.map do |i| 
    zh = i.split('\N')[0]
    en = i.split('\N')[1]
#    p zh
#    p en
  end
end
$input = ARGV[0]
def ass2txt input
  # expand input out path first, or else
  # e.g input is 'user', output if 'other'
  # /home/user/user will be replaced as /home/other/user, wrong!
  # should be /home/user/other ya
  # if we expand the path, that won't happen
  input = File.expand_path $input
  Find.find(input) do |file|
    next unless file =~ /ass$/i
    next if File.directory?(file)
    file_base_name = File.basename(file, '.ass') # $inputfile is filename. , with a dot
    en_filename = file_base_name + '_en.txt'
    zh_filename = file_base_name + '_zh.txt'
    path = File.dirname(file)
    puts "正在处理： #{file}"
    str = File.read file
    arr = str.split(/^Dialogue:/).map do |i| 
      i = i.slice(54,1000)
      #    p i
    end
    arr = arr.reject {|i| i == nil}
    arr = arr.map do |i|
      # i = i.gsub(/<[^>]+>/,'')  # 删除这种垃圾 <font color=\"#ffff00\">
      i = i.gsub(/{.+[^{]+}/,'')  # 删除这种垃圾   {\fn微软雅黑\fs20}
      i = i.gsub(/\n/,'')  # no newline needed
      #    i = i.strip
      #   p i
    end
    all_zh_lines = []
    all_en_lines = []
    arr.map do |i| 
      zh = i.split('\N')[0]
      en = i.split('\N')[1]
      all_zh_lines << zh
      all_en_lines << en
      #p zh
      #p en
#      p all_zh_lines
#      p all_en_lines
    end
    puts "正在生成 #{zh_filename}, #{en_filename}"
    puts ""
    File.open("#{path}/#{en_filename}", 'w') do |f| # append mode
      f.puts all_en_lines.join("\n")
    end
    File.open("#{path}/#{zh_filename}", 'w') do |f| # append mode
      f.puts all_zh_lines.join("\n")
    end
  end
end

ass2txt $input

s = '''
Dialogue: 0,0:00:07.80,0:00:10.05,*Default,NTP,0000,0000,0000,,我想简单宣传一下我们这个演说台\N{\fn方正综艺简体}{\fs14}{\b0}{\c&HFFFFFF&}{\3c&H2F2F2F&}{\4c&H000000&}I want to just say a word about soapbox 

Dialogue: 0,0:00:10.26,0:00:12.19,*Default,NTP,0000,0000,0000,,那些第一次来这儿的人\N{\fn方正综艺简体}{\fs14}{\b0}{\c&HFFFFFF&}{\3c&H2F2F2F&}{\4c&H000000&}for those of you who are first time into 
'''
#get_ass_text s
