# -*- coding: utf-8 -*-
require 'csv'
require 'fileutils'

# usage:  script en.srt ch.srt

# 将英文和中文分开的srt文件合并到一个csv中
# 输出文件在 

EN = ARGV[0]
ZH = ARGV[1]
OUTPUT = 'srt_csv'

def splitfile(file)
  str = File.read(file)
  str = str.encode('utf-8', 'utf-16')
  str = str.gsub(/\r/,"\n")
  str = str.gsub(/\n\n+/,"\n")
  str = str.gsub(/<[^>]+>/,'')  # 删除这种垃圾 <font color=\"#ffff00\">
  arr = str.split(/^[0-9]+$/) #不要忘记了$否则会匹配到时间线
  arr.shift
  arr
end
def timeline_text_hash(arr)
  rst = {}
  arr.each do |i|
    i = i.split(/\n/)
    # 单条记录 => ["", "00:00:41,412 --> 00:00:42,904", "so I wanted to share it with you."]
    i.shift  # 第一个元素是空的 # 第一个元素是空的
    key = i[0]
    value =i[1]
    rst[key] = value
  end
  rst
end
def file_with_bom
  Dir.mkdir(OUTPUT) unless File.exist?(OUTPUT)
#  oldname = ZH
  #newname = oldname.sub('.chs.srt', 'combined.srt')
  File.open("#{OUTPUT}/#{ZH}.csv", 'w')do |f|
    f.puts  "\uFEFF"
  end
end
def write_to_file(hash_en, hash_zh)
  # 悲剧，ruby的csv默认就是不quote值，浪费了半个小时才找到:force_quote用法
  # http://stackoverflow.com/questions/5831366/quote-all-fields-in-csv-output
  CSV.open("srt_csv/#{ZH}.csv", 'a', {:force_quotes=>true}) do |csv| # append mode
    hash_en.keys.each do |key|
      zh = hash_zh[key]
      en = hash_en[key]
      csv << [zh,en]
    end
  end
end
def combine_src(en_srt, zh_srt)
  en_arr = splitfile(en_srt)
  zh_arr = splitfile(zh_srt)
  file_with_bom
  hash_en = timeline_text_hash(en_arr)
  hash_zh = timeline_text_hash(zh_arr)
  write_to_file(hash_en, hash_zh)
end


combine_src(EN, ZH)

#p splitfile(EN)
#p splitfile(ZH)
# hash_en = timeline_text_hash(splitfile(EN))

