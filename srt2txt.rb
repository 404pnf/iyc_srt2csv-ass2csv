# -*- coding: utf-8 -*-
require 'find'
require 'fileutils'
require 'csv'

#时间戳作为键，然后chs/eng作为下一级别的key
#可以尝试用symbol哟 ：）
#hash[timstamp][chs] = 中文翻译
#hash[timstamp][eng] = 中文翻译

# nested hash
# http://www.dzone.com/snippets/create-nested-hashes-ruby
# http://www.ruby-forum.com/topic/140570
# this one only two level deep, it works here but not in general sense
# hash = Hash.new { |h,k| h[k] = {} }
# unlimited depth
# blk = lambda {|h,k| h[k] = Hash.new(&blk)}
# x = Hash.new(&blk)
# x[:la][:li][:lu][:chunky][:bacon][:foo] = "bar"
# hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }

# $input = ARGV[0].chomp('/')
# $output = ARGV[1].chomp('/')

def split_srt(str)
#  str = File.read(file)
#  str = str.encode('utf-8', 'utf-16le') # need to be specific utf-16le for mac osx compatability
  str = str.gsub(/\r/,"\n")
  str = str.gsub(/\n\n+/,"\n")
  # 去掉这些垃圾<font color=#00FF00>【  -=THE LAST FANTASY=- 荣誉出品  】</font>
  str = str.gsub(/<[^>]+>/,'')  # 删除这种垃圾 <font color=\"#ffff00\">
  str = str.gsub(/{.+[^{]+}/,'')  # 删除这种垃圾   {\fn微软雅黑\fs20}
  str = str.gsub('\N','')

#  str = str.sub(/^A/, "0\na\n\n") # to fix the following bug
  # the first 
  # 1 
  # video transcript
  arr = str.split(/^[0-9]+$/) 
  #  p arr
  # strange?!
  # first item is 
  # "1 "
  # ["1 00:00:02,130 --> 00:00:03,910 Prof: Good morning everyone. ", " 00:00:03,910 --> 00:00:07,300 As you can see from today's lecture title, ", " 00:00:07,300 --> 00:00:14,520 we're going to be talking about painting palaces and villas in the first century A.D. "] 
  # don't know how the number 1 get in front of the timestamp and I can't get it out of it
  newarr = arr.map {|i| i.gsub(/\n/, ' ').gsub(/  +/, ' ')} # some translation spread into twol lines
 # newarr[0] = newarr[0].slice(2,10000) # don't know to to say slice(1, end)
  #p newarr[0]
  return newarr # 必须有这行，否则最后输出的是组后求值的arr.shift，成了""啦！用return关键字提醒一下 
  
end
def srt_generate_hash(array)
  hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
  array.each do |line|
    # [" 00:44:49,210 --> 00:44:49,810 Yes? ", " 00:44:49,810 --> 00:44:51,110 Student: And will you hold office hours? ",]
    timestamp = line.slice(0,31) unless line == nil
    content = line.slice(31,1000000) unless line == nil
    # => "00:44:49,810 --> 00:44:51,110"
    hash[timestamp][:chs] = content
    hash[timestamp][:eng] = content
  end
  array = hash.sort_by {|k,v| k} #用timestamp排序
end
# a=  ["\n00:00:01,810 --> 00:00:03,600\n好的  一百五十年来\nOkay. So for 150 years\n", "\n00:00:03,600 --> 00:00:12,180\n有机化学课程似乎令人闻之却步\norganic chemistry courses have tended to acquire a daunting reputation. \n"]
# p srt_generate_hash(a)
def srt_gen_eng_hash(array)
  hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
  array.each do |line|
    timestamp = line.slice(0,31) unless line == nil
#    timestamp = line.slice(0,12) unless line == nil
    content = line.slice(31,1000000) unless line == nil
    # => "00:44:49,810 --> 00:44:51,110"
    hash[timestamp][:eng] = content
  end
  hash
end
def srt_gen_chs_hash(array)
  hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
  array.each do |line|
    timestamp = line.slice(0,31)
    content = line.slice(31,1000000)
    # => "00:44:49,810 --> 00:44:51,110"
    hash[timestamp][:chs] = content
  end
  hash
end
def file_with_bom
  # excel不认识utf-8的csv文件，必须加不合规范的BOM头
  # 参考： http://stackoverflow.com/questions/155097/microsoft-excel-mangles-diacritics-in-csv-files
  FileUtils.mkdir_p("#{$newpath}") unless File.exist?("#{$newpath}")
  File.open("#{$newpath}/#{$inputfile}csv", 'w')do |f|
    f.puts  "\uFEFF"
  end
end
def write_to_file(arr)
  # 悲剧，ruby的csv默认就是不quote值，浪费了半个小时才找到:force_quote用法
  # http://stackoverflow.com/questions/5831366/quote-all-fields-in-csv-output
  CSV.open("#{$newpath}/#{$inputfile}csv", 'a', {:force_quotes=>true}) do |csv| # append mode
    arr.each do |item| 
      # each item is 
      # => ["00:44:51,110 --> 00:44:52,660", [{:chs=>"我的答疑时间么？"}, {:eng=>"Prof: Will I hold office hours?"}]]
      # some times the timestamp of eng and chs are different!!!!!
      # which makes that particular timestamp by itself
      # this bug is so hard to find out!!!
      # shame those who change the time axis
      # e.g
      # 
      #      => [" 00:00:51,000 --> 00:00:56,000 ", [{:chs=>"注册周一开始，但周一只允许大一大二的注册 "}, {:eng=>"That'll start on Monday but it'll only start for freshman and sophomores on Monday "}]]
      #irb(main):300:0> a[15]
      # /// eng ends at 01:00, chs ends at 01:02 !!!!!
      #      => [" 00:00:56,000 --> 00:01:00,000 ", {:eng=>"Juniors and seniors will be able to sign up for the course and sign for "}]
      #irb(main):301:0> a[16]
      #      => [" 00:00:56,000 --> 00:01:02,000 ", {:chs=>"大三大四的周二才能注册 "}]
      #irb(main):302:0> a[17]
      #      => [" 00:01:00,000 --> 00:01:04,000 ", {:eng=>"sections on Tuesday, and so please do that "}]
      #irb(main):303:0> a[18]
      #      => [" 00:01:02,000 --> 00:01:04,000 ", {:chs=>"请按照要求来 "}]

      if item.is_a? Array # it's supposed to be an array
        zh = item[1][0][:chs]
      else # else it's a hash
        zh = item[1].values
      end
      if item.is_a? Array
        en = item[1][1][:eng]
      else
        en = item[1].values
      end
      p zh
      p en
      csv << [zh,en]
    end
  end
end
def ending_msg
  puts "========================================="
  puts "da di di da da"
  puts ''
  puts "都转好了，请查看 #{File.expand_path $output} 目录。"
  puts ''
  puts '========================================='
end
# usage: script.rb inputfolder outputfolder

$input = File.expand_path(ARGV[0])
$output = File.expand_path(ARGV[1])
def all_in_one(input, output)

  input = $input
  output = $output

  all_dirs = []

  Find.find(input) do |d|
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
    #p filepath
    $newpath = filepath.sub(input, output)
    #    p $newfilepath
    $inputfile = File.basename(zh_file, 'srt')
    p "transforming: #{$inputfile} \n"
    arr_zh = split_srt(File.read(zh_file))
    #    p arr_zh
    arr_en = split_srt(File.read(en_file))
    #   p arr_en
    hash_zh = srt_gen_chs_hash(arr_zh)
    hash_en = srt_gen_eng_hash(arr_en)
    hash_all = hash_zh.merge(hash_en) {|k, chs, eng| [chs, eng]}
    csv_arr = hash_all.sort_by {|k, v| k} # k is timestampe, sort by it
    csv_arr
    file_with_bom
    write_to_file(csv_arr)
  end
#  ending_msg
end

all_in_one($input, $output)
