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

class String

 def split_srt
 #  str = File.read(file)
 #  str = str.encode('utf-8', 'utf-16le') # need to be specific utf-16le for mac osx compatability

   str = ''
   str = self.gsub(/\r/,"\n")
   str = str.gsub(/\n\n+/,"\n")
   # 去掉这些垃圾<font color=#00FF00>【  -=THE LAST FANTASY=- 荣誉出品  】</font>
   str = str.gsub(/<[^>]+>/,'')  # 删除这种垃圾 <font color=\"#ffff00\">
   arr = str.split(/^[0-9]+$/) 
   arr.shift # 第一行是个空的
   return arr # 必须有这行，否则最后输出的是组后求值的arr.shift，成了""啦！用return关键字提醒一下自己
 end
 def split_ass
   str = self.gsub(/\r/,"\n")
   str = str.gsub(/\n\n+/,"\n")
   str = str.gsub(/{[^}]+}/, '')
   array = str.split(/\n/)
   array = array.reject {|i|  !(i =~ /^Dialogue/) }
 end
end

class Array

 def srt_generate_hash
   hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
   self.each do |line|
     arr = line.split(/\n/)
     # arr ["", "00:00:01,810 --> 00:00:03,600", "好的  一百五十年来", "Okay. So for 150 years"]
     timestamp = arr[1].split('-->')[0].to_s # starting time is enough for key
     hash[timestamp][:chs] = arr[2]
     hash[timestamp][:eng] = arr[3]
   end
   hash
 end
 def srt_gen_eng_hash
   hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
   self.each do |line|
     arr = line.split(/\n/)
     # arr ["", "00:00:01,810 --> 00:00:03,600", "it's english, englishx", "Okay. So for 150 years"]
     timestamp = arr[1].split('-->')[0].to_s # starting time is enough for key
     hash[timestamp][:eng] = arr[2..-1].join(' ') # 这里是range .. 不要用错用成逗号啊！！！ ：） 
   end
   hash
 end
 def srt_gen_chs_hash
   hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
   self.each do |line|
     arr = line.split(/\n/)
     # line ["", "00:00:01,810 --> 00:00:03,600", "中文啦", "还是中文啦"]
     timestamp = arr[1].split('-->')[0].to_s # 注意切分后时间字符串后面有个空格，如果翻译人员多加了空格，那么时间会混乱，稍后改进。starting time is enough for key
     hash[timestamp][:chs] = arr[2..-1].join(' ') # 字母字段从 index 2 开始啦！ 
 #.join('  ')
   end
   hash
 end
 def ass_generate_hash
   hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
   self.each do |line|
     arr = line.split(/,/)
     
     # here, the \N in arr[9] is replaced with N
     # WTF!!!??
     #irb(main):001:0> File.read('test.txt')
     #=> "1111\\N2222\n"
     #irb(main):002:0> File.read('test.txt').split('\N')
     #=> ["1111", "2222\n"]
     #p arr
     #p arr[9]
     # read from file is OK?
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
     
=begin
     irb(main):035:0> a = '1,2\N3'
     => "1,2\\N3"
     irb(main):036:0> a.split(',')
     => ["1", "2\\N3"]
     irb(main):037:0> a.split(',')[1]
     => "2\\N3"
     irb(main):038:0> a.split(',')[1].split(/\N/)
     => ["2\\", "3"]
     irb(main):039:0> a.split(',')[1].split(/\\N/)
     => ["2", "3"]
     # notice the diffrence o \N, single quotes and double quotes!
     irb(main):033:0> d = "NN\NNN"
     => "NNNNN"  # we lost \N
     irb(main):034:0> d = 'NN\NNN'
     => "NN\\NNN" # double back slash 
=end
     p arr[9]
     p text
     # 如果 lang 这个项目是 *Default，那么输入的文字是中文和英文在一起的，需要用其它逻辑
     # 比如 Dialogue: 0,0:00:40.58,0:00:45.39,*Default,NTP,0000,0000,0000,,那些将都是实的 但在那之前\NAnd that will be mostly real. But at one point somewhere,
     # p lang.downcase
     if lang.downcase == "*default"
       r = text.split('\N')
       # text is an array item, we get the array by split method on a string
       # therefore, if the string contains \N, in the array item, it becomse \\N
       #irb(main):044:0> a
       #=> "1,2\\N3"
       #irb(main):045:0> a.split(',')
       #=> ["1", "2\\N3"]
       #irb(main):046:0> a.split(',')[1].to_s
       #=> "2\\N3"
       # this BITES me!!!
       #irb(main):048:0> a.split(',')[1].split(/\\N/)
       #=> ["2", "3"]
       #irb(main):049:0> a.split(',')[1].split(/\N/)
       #=> ["2\\", "3"]
       #这里使用双引号是错误的，看！！！
       #irb(main):027:0> d = 'NN\NNN'
       #=> "NN\\NNN"
       #irb(main):028:0> d.split('\N')
       #=> ["NN", "NN"]
       #irb(main):029:0> d.split("\N"
       #p r #这里如果用split('\N')就无法正常分割，如果用 /\N/ 报unknow regex，但正常工作，不知到为什么
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
       #p text
       hash[timestamp][lang.to_sym] = text.gsub('\N', ' ') # 这里的sub没有成功
     end
   end
   hash
 end
end
#str = 'Dialogue: 0,0:00:40.58,0:00:45.39,*Default,NTP,0000,0000,0000,,那些将都是实的 但在那之前\Nthat will be mostly real. But at one point somewhere,'
# generate_hash(str)
class Hash
   def sort_by_timestamp
     return self.sort_by {|k,v| k} #用timestamp排序
     # $hash在排序后变为了数组
     # a = ["0:00:00.00", {:chs=>"我是沃尔特-文", :eng=>"I'm Walter Lewin."}]
     # > a[1][:chs]
     # => "我是沃尔特-略文"
     # > a[1][:eng]
     # => "I'm Walter Lewin."
   end
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
#=begin
#ass = <<- 'eof' 
ass = '''
# so no interplation 

#Dialogue: 0,0:07:54.50,0:06:58.53,Chs,,0000,0000,0000,,中文1111111111111.
#Dialogue: 0,0:07:54.50,0:06:58.53,eng,,0000,0000,0000,,english11111111111111.


#Dialogue: 0,0:06:55.50,0:06:58.53,*Default,,0000,0000,0000,,没有声明语言.\Nno language code declared.


#Dialogue: 0,0:06:56.50,0:06:58.53,chs,,0000,0000,0000,,有英文,逗号
#Dialogue: 0,0:06:56.50,0:06:58.53,eng,,0000,0000,0000,,has english,comma


#Dialogue: 0,0:06:56.51,0:06:58.53,*Default,,0000,0000,0000,,有英文逗号,且没有生命语言！,只要有反斜杠N就能正确处理.\NEnglish comma, here

Dialogue: 0,0:06:56.52,0:06:58.53,eng,,0000,0000,0000,,English with \b\a\c\kslash N\N how about that

# 注意下面两中文条目个时间起点一样！！后面的会冲掉前面的。因为在写后面的时候，等于更新了该时间键对应的值
#Dialogue: 1,0:29:04.00,0:29:22.00,kak,,0000,0000,0000,,函数一：距离\N函数二：匀变速的速度
#Dialogue: 1,0:29:04.00,0:29:22.00,kak,,0000,0000,0000,,kak, kak\N竟然有中文在kak中
#Dialogue: 1,0:29:04.00,0:29:22.00,eng,,0000,0000,0000,,eng, 对应kak的english
eof
'''
# bitten by heredoc!!! so hard!
#=end
#p 'ass'
p ass.split_ass.ass_generate_hash.sort_by_timestamp
p ass.split_ass
#=begin
# srt file format
str = <<eof
1
00:00:01,810 --> 00:00:03,600
好的  一百五十年来
Okay. So for 150 years

2
00:00:03,600 --> 00:00:12,180
有机化学课程似乎令人闻之却步
organic chemistry courses have tended to acquire a daunting reputation. 
eof
#=end
#p 'srt'
#p str.split_srt.srt_generate_hash.sort_by_timestamp
#p str.split_srt.srt_gen_eng_hash.sort_by_timestamp
