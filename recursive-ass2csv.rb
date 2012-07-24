# -*- coding: utf-8 -*-
require './lib/recursive-ass2csv.rb'


def r_ass2csv(dir)
  dir = dir.chomp('/') # de-slash
  Find.find(dir) do |file|
    next unless file =~ /ass$/i
    next if File.directory?(file)
    $inputfile = File.basename(file)
    path = (File.expand_path(file)).split('/') # path now is absolute with root /, e.g /home/user/file.ass
    path.pop # remove filename
    path.shift # remove leading ""
    path = path.join('/')
    path = path.sub(/\A/, '/') # add root directory
    $newpath = path.sub('source', 'target')
    puts "正在处理： #{file}"
    puts ""
    ass2csv(file) # defined in lib/recursive-ass2csv.rb
  end
  puts "========================================="
  puts "da di di da da"
  puts ''
  puts "都转好了，请查看当前目录下的target目录。"
  puts ''
  puts '========================================='
end
r_ass2csv(ARGV[0])
