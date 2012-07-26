# -*- coding: utf-8 -*-
require 'fileutils'
def sanitize(title)
  # 不要替换 / 否则路径分割符号也被替换了
  # 因为下面的file是含有路径的
  # 也不要替换英文句号，因为作文文件后缀分割符号
  # 例子： "source//TLF/PBS自由选择/PBS.自由选择_2_/_PBS自由选择_PBS.Free_to_Choose_1990.Vol.4"
  title = title.tr(' `~!@#$%^&*()_+=\|][{}"\';:>,<', '_')
  title = title.tr('－·～！@#￥%……&*（）——+、|】』【『‘“”；：。》，《', '_')
  title = title.gsub(/_+/, '_').gsub(/^_/, '').gsub(/_$/, '') # 对开头，结尾和多个 _ 做处理

  title = title.gsub('_/', '/') #如果路径分割前后有下划线也不要
  title = title.gsub('/_', '/')
  # 不知何时引入了多个连续的 // 可这 连续的 // 给我伤害
  # 哦，我只到何时引入的了，是ARGV[0]没有chomp掉目录的结尾 /
  title = title.gsub(/\/\/+/, '/')
end
def recursive_rename(dir)
  Dir.glob("#{dir}/**/*").each do |file|
    #p file
    abs_fn = File.expand_path(file)
    newfilename = sanitize(file)
    path = (File.expand_path(newfilename)).split('/') # path now is absolute with root /, e.g /home/user/file.ass
    path.pop # remove filename
    path.shift # remove leading ""
    path = path.join('/')
    path = path.sub(/\A/, '/') # add root directory
    newpath = path.sub('source', 'haha')
    newfilename = newfilename.sub('source', 'haha')
 #   p newpath
    FileUtils.mkdir_p(newpath) unless File.exist?(newpath)
    next unless newfilename =~ /(srt|ass)$/i
#    p newfilename
#    p file
    p abs_fn
    p newfilename

    FileUtils.cp(abs_fn, newfilename, :verbose => true)
  end  
end

recursive_rename(ARGV[0].chomp('/'))

