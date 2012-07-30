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
  arr = str.split(/^[0-9]+$/) 
  arr.shift # 第一行是个空的
  return arr # 必须有这行，否则最后输出的是组后求值的arr.shift，成了""啦！用return关键字提醒一下自己
  # p arr
  # arr now is  
  # a=  ["\n00:00:01,810 --> 00:00:03,600\n好的  一百五十年来\nOkay. So for 150 years\n", "\n00:00:03,600 --> 00:00:12,180\n有机化学课程似乎令人闻之却步\norganic chemistry courses have tended to acquire a daunting reputation. \n"]
end
def srt_generate_hash(array)
  hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
  array.each do |line|
    arr = line.split(/\n/)
    # arr ["", "00:00:01,810 --> 00:00:03,600", "好的  一百五十年来", "Okay. So for 150 years"]
    timestamp = arr[1].split('-->')[0].to_s # starting time is enough for key
    hash[timestamp][:chs] = arr[2]
    hash[timestamp][:eng] = arr[3]
  end
  array = hash.sort_by {|k,v| k} #用timestamp排序
end
# a=  ["\n00:00:01,810 --> 00:00:03,600\n好的  一百五十年来\nOkay. So for 150 years\n", "\n00:00:03,600 --> 00:00:12,180\n有机化学课程似乎令人闻之却步\norganic chemistry courses have tended to acquire a daunting reputation. \n"]
# p srt_generate_hash(a)
def srt_gen_eng_hash(array)
  hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
  array.each do |line|
    arr = line.split(/\n/)
    # arr ["", "00:00:01,810 --> 00:00:03,600", "it's english, englishx", "Okay. So for 150 years"]
    timestamp = arr[1].split('-->')[0].to_s # starting time is enough for key
    hash[timestamp][:eng] = arr[2..-1].join(' ') # 这里是range .. 不要用错用成逗号啊！！！ ：） 
  end
  hash
end
def srt_gen_chs_hash(array)
  hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
  array.each do |line|
    arr = line.split(/\n/)
    # line ["", "00:00:01,810 --> 00:00:03,600", "中文啦", "还是中文啦"]
    timestamp = arr[1].split('-->')[0].to_s # 注意切分后时间字符串后面有个空格，如果翻译人员多加了空格，那么时间会混乱，最好方法是chomp一下。稍后改进。starting time is enough for key
    hash[timestamp][:chs] = arr[2..-1].join(' ') # 字母字段从 index 2 开始啦！ 
#.join('  ')
  end
  hash
end
#arr =  ["\n00:00:01,810 --> 00:00:03,600\n好的  一百五十年来\nOkay. So for 150 years\n", "\n00:00:03,600 --> 00:00:12,180\n有机化学课程似乎令人闻之却步\norganic chemistry courses have tended to acquire a daunting reputation. \n"]
#h1 =  srt_gen_chs_hash(arr)
#h2 = srt_gen_eng_hash(arr)
#p h1.merge(h2) {|k,v1,v2| [v1, v2]}

def generate_hash(array)
  hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
  array.each do |line|
    arr = line.split(/,/)
    timestamp = arr[1].to_s # starting time is enough for key
    lang = arr[3].to_s.downcase
    # 按说这个格式是严格的，因此可以直接用逗号分割
    # !错误，翻译中也有英文逗号，因此不能直接用逗号分割
    # 因此，应该把index 9 之后的所有元素都算为text才对
    # 需要还原之前的英文逗号，因此先join一下
    if arr.size > 9
      text = arr[9..-1].join(',').to_s 
    else
      text = arr[9].to_s
    end
    # 如果 lang 这个项目是 *Default，那么输入的文字是中文和英文在一起的，需要用其它逻辑
    # 比如 Dialogue: 0,0:00:40.58,0:00:45.39,*Default,NTP,0000,0000,0000,,那些将都是实的 但在那之前\NAnd that will be mostly real. But at one point somewhere,
    # p lang.downcase
    if lang.downcase == "*default"
      r = text.split('\N')
      hash[timestamp][:chs] = r[0]
      hash[timestamp][:eng] = r[1]
    elsif lang.downcase == 'kak'
      hash[timestamp][:chs] = text.sub('\N', ' ') # 有些中文翻译的lang竟然是 kak
      # 本身这个kak是留给写翻译组参与翻译人的姓名等信息的不应该写翻译本身
      # oCourse-renamed/微积分重点/1.ass:Dialogue: 1,0:29:04.00,0:29:22.00,kak,,0000,0000,0000,,函数一：距离\N函数二：匀变速的速度
      # 而且竟然也用到了换行符号 
      # 采用这个格式是错误的，应该报告给翻译组
      # 我们在此处理一下
    else
      hash[timestamp][lang.to_sym] = text.sub('\N', ' ')
    end
  end
  array = hash.sort_by {|k,v| k} #用timestamp排序
  # $hash在排序后变为了数组
  # a = ["0:00:00.00", {:chs=>"我是沃尔特-文", :eng=>"I'm Walter Lewin."}]
  # > a[1][:chs]
  # => "我是沃尔特-略文"
  # > a[1][:eng]
  # => "I'm Walter Lewin."
end
#str = 'Dialogue: 0,0:00:40.58,0:00:45.39,*Default,NTP,0000,0000,0000,,那些将都是实的 但在那之前\Nthat will be mostly real. But at one point somewhere,'
# generate_hash(str)
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
      zh = item[1][:chs]
      en = item[1][:eng]
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
# ass file format
=begin
str =<<eof
Dialogue: 0,0:07:54.50,0:06:58.53,Chs,,0000,0000,0000,,第二部分.
Dialogue: 0,0:07:54.50,0:06:58.53,eng,,0000,0000,0000,,second part.
Dialogue: 0,0:06:54.50,0:06:58.53,Chs,,0000,0000,0000,,从而推动科学的发展.
Dialogue: 0,0:06:54.50,0:06:58.53,eng,,0000,0000,0000,,promote the progress of science.
Dialogue: 0,0:06:55.50,0:06:58.53,*Default,,0000,0000,0000,,没有声明语言.
Dialogue: 0,0:06:55.50,0:06:58.53,*Default,,0000,0000,0000,,no language code declared.
Dialogue: 0,0:06:55.50,0:06:58.53,*Default,,0000,0000,0000,,有英文逗号,还有.
Dialogue: 0,0:06:55.50,0:06:58.53,*Default,,0000,0000,0000,,with comma, another one, ha.
Dialogue: 1,0:29:04.00,0:29:22.00,kak,,0000,0000,0000,,函数一：距离\N函数二：匀变速的速度
Dialogue: 1,0:29:04.00,0:29:22.00,kak,,0000,0000,0000,,kak, kak\N竟然有中文在kak中
eof
=end

=begin
# srt file format
1
00:00:01,810 --> 00:00:03,600
好的  一百五十年来
Okay. So for 150 years

2
00:00:03,600 --> 00:00:12,180
有机化学课程似乎令人闻之却步
organic chemistry courses have tended to acquire a daunting reputation. 
=end
