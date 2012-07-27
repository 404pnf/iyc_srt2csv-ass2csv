# -*- coding: utf-8 -*-
require 'pp'
str =<<eof
Dialogue: 0,0:06:54.50,0:06:58.53,Chs,,0000,0000,0000,,从而推动科学的发展.
eof

#有时间戳作为键，然后chs/eng作为下一级别的key
#可以尝试用symbol哟 ：）
#hash[timstamp][chs] = 中文翻译
#hash[timstamp][eng] = 中文翻译
# 按说这个格式是严格的，因此可以直接用逗号分割

# nested hash
# http://www.ruby-forum.com/topic/140570
# this one only two level deep, it works here but not in general sense
# hash = Hash.new { |h,k| h[k] = {} }
hash = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
def generate_hash(str)
  arr = str.chomp!.split(',')
  timestamp = "#{arr[1]},#{arr[2]}"
  lang = arr[3]
  text = arr[9]
  p timestamp
  p lang
  p text
  hash[timestamp][lang] = text
  p hash
end

generate_hash(str)
