# -*- coding: utf-8 -*-
require 'csv'
require 'fileutils'
require 'find'

# usage:  script en.srt ch.srt

# 将英文和中文分开的srt文件合并到一个csv中
# 输出文件在 

OUTPUT = 'srt_csv'



def splitfile(file)
  str = File.read(file)
#  str = str.encode('utf-8', 'utf-16')
  str = str.gsub(/\r/,"\n")
  str = str.gsub(/\n\n+/,"\n")
  str = str.gsub(/<[^>]+>/,'')  # 删除这种垃圾 <font color=\"#ffff00\">
  arr = str.split(/^[0-9]+$/) #不要忘记了$否则会匹配到时间线
  arr.shift
  arr
end
def split_ascii_file(file)
  str = File.read(file)
#  str = str.encode('utf-8', 'utf-16')
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
  File.open("#{OUTPUT}/#{$filename}", 'w')do |f|
    f.puts  "\uFEFF"
  end
end
def write_to_file(hash_en, hash_zh)
  # 悲剧，ruby的csv默认就是不quote值，浪费了半个小时才找到:force_quote用法
  # http://stackoverflow.com/questions/5831366/quote-all-fields-in-csv-output
    CSV.open("#{OUTPUT}/#{$filename}", 'a', {:force_quotes=>true}) do |csv| # append mode
      hash_en.keys.each do |key|
        zh = hash_zh[key]
        en = hash_en[key]
        csv << [zh,en]
      end
    end
end
def combine_src(en_srt, zh_srt)
  en_arr = split_ascii_file(en_srt)
  zh_arr = splitfile(zh_srt)
  file_with_bom
  hash_en = timeline_text_hash(en_arr)
  hash_zh = timeline_text_hash(zh_arr)
  write_to_file(hash_en, hash_zh)
end


# recursively get all dirs
# input a dir
# an array contains all dirs to traverse
def r_get_dir(dir)
  all_dirs = []
  Find.find(dir) do |d|
    if File.directory? d
      all_dirs << d
    end
  end
  all_dirs
end
def only_two_files?(dir)
  if Dir.glob("*.srt").size == 2 # return a array
    true
  else
    nil
  end
end
def cmb_two_files
  en_arr = split_ascii_file(en_srt)
  zh_arr = splitfile(zh_srt)
  file_with_bom
  hash_en = timeline_text_hash(en_arr)
  hash_zh = timeline_text_hash(zh_arr)
  write_to_file(hash_en, hash_zh)
end

def all_in_one(dir)
  all_dirs = []
  Find.find(dir) do |d|
    if File.directory? d
      all_dirs << d
    end
  end
  all_dirs.each do |d2|
    if Dir.glob("*.srt").size != 2 # return an array
      all_dirs.delete(d2)
    end
  end
  all_dirs.each do |d3|
    filelist = Dir.glob("#{d3}/*.srt") # return an array
    zh_file = filelist[0] # we don't actually know the first item is zh_file but we don't care
    en_file = filelist[1] # we only care about assigning them to tow variables
    $filename = File.basename(zh_file).sub(/(eng.srt$|chs.srt$)/, 'cmb.srt') # rename
    p $filename
    en_arr = split_ascii_file(en_file)
    zh_arr = splitfile(zh_file)
    file_with_bom
    hash_en = timeline_text_hash(en_arr)
    hash_zh = timeline_text_hash(zh_arr)
    write_to_file(hash_en, hash_zh)
  end
end

all_in_one(ARGV[0].chomp('/'))
#combine_src(EN, ZH)


