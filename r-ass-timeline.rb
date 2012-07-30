# -*- coding: utf-8 -*-
require 'find'
require 'fileutils'
require 'csv'

#有时间戳作为键，然后chs/eng作为下一级别的key
#可以尝试用symbol哟 ：）
#hash[timstamp][chs] = 中文翻译
#hash[timstamp][eng] = 中文翻译
# 按说这个格式是严格的，因此可以直接用逗号分割

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

$input = ARGV[0].chomp('/')
$output = ARGV[1].chomp('/')
$hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
$array = [] # for array to csv
def generate_hash(str)
  str.gsub!(/\r/,"\n")
  str.gsub!(/\n\n+/,"\n")
  str.gsub!(/{[^}]+}/, '')
  array = str.split(/\n/)
  array = array.reject {|i|  !(i =~ /^Dialogue/) }
  array.each do |line|
    arr = line.split(',')
    timestamp = arr[1].to_s # starting time is enough for key
    lang = arr[3].to_s.downcase
    text = arr[9].to_s
    $hash[timestamp][lang.to_sym] = text
  end
  $array = $hash.sort_by {|k,v| k} #用timestamp排序
  # $hash在排序后变为了数组
  # a = ["0:00:00.00", {:chs=>"我是沃尔特-文", :eng=>"I'm Walter Lewin."}]
  # > a[1][:chs]
  # => "我是沃尔特-略文"
  # > a[1][:eng]
  # => "I'm Walter Lewin."
end
#generate_hash(file)
def file_with_bom
  FileUtils.mkdir_p("#{$newpath}") unless File.exist?("#{$newpath}")
  File.open("#{$newpath}/#{$inputfile}csv", 'w')do |f|
    f.puts  "\uFEFF"
  end
end
def write_to_file(arr)
  # 悲剧，ruby的csv默认就是不quote值，浪费了半个小时才找到:force_quote用法
  # http://stackoverflow.com/questions/5831366/quote-all-fields-in-csv-output
  CSV.open("#{$newpath}/#{$inputfile}csv", 'a', {:force_quotes=>true}) do |csv| # append mode
    p $array
    $array.each do |item| 
      zh = item[1][:chs]
      en = item[1][:eng]
      p zh
      csv << [zh,en]
    end
  end
end
def ending_msg
  puts "========================================="
  puts "da di di da da"
  puts ''
  puts "都转好了，请查看#{File.expand_path $output}目录。"
  puts ''
  puts '========================================='
end
def ass2csv(file)
  input = File.read(file)
  generate_hash(input)
  file_with_bom
  write_to_file $array
end
def r_ass2csv(input, output)
  # expand input out path first, or else
  # e.g input is 'user', output if 'other'
  # /home/user/user will be replaced as /home/other/user, wrong!
  # should be /home/user/other ya
  # if we expand the path, that won't happen
  input = File.expand_path $input
  output = File.expand_path $output 
  
  Find.find(input) do |file|
    file = file.downcase
    next unless file =~ /ass$/
    next if File.directory?(file)
    $inputfile = File.basename(file, 'ass') # $inputfile is filename. , with a dot
    $inputpath = File.dirname(file)
    $newpath = $inputpath.sub(input, output)
    puts "正在处理： #{file}"
    puts ""
    ass2csv(file) # defined in lib/recursive-ass2csv.rb
  end
  ending_msg
end
r_ass2csv($input, $output)
#p $array

=begin
str =<<eof

Dialogue: 0,0:07:54.50,0:06:58.53,Chs,,0000,0000,0000,,第二部分.

Dialogue: 0,0:07:54.50,0:06:58.53,eng,,0000,0000,0000,,second part.


Dialogue: 0,0:06:54.50,0:06:58.53,Chs,,0000,0000,0000,,从而推动科学的发展.

Dialogue: 0,0:06:54.50,0:06:58.53,eng,,0000,0000,0000,,promote the progress of science.

eof
=end
