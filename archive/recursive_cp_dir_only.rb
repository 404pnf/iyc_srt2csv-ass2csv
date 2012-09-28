# -*- coding: utf-8 -*-
def cp_folder(folder)
  Find.find(folder) do |path|
    next unless File.directory? path
    path = path.sub('srt','csv')
    FileUtils.mkdir_p(path)
  end
end


# BASH remove exmpty dirs
# find . -type d -empty -exec rmdir '{}' \;
# http://stackoverflow.com/questions/1290670/ruby-how-do-i-recursively-find-and-remove-empty-directories

# RUBY remove empty dirs
# Dir['**/*']
#   .select { |d| File.directory? d }
#   .select { |d| (Dir.entries(d) - %w[ . .. ]).empty? } # '-' 是减号，第一个数组减第二个数组 就是排除 .. 和 .. 两个目录后，如果数组为空，证明该目录下没有任何文件
#   .each   { |d| Dir.rmdir d }
# http://stackoverflow.com/questions/1290670/ruby-how-do-i-recursively-find-and-remove-empty-directories

