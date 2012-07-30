

# split an file path to path and filename, e.g /path/to/file.txt
# return is an array, MatchData object
# return[0] is the whole match
# return[1] is the path
# return[2] is the filename

# 1. will NOT work on a path ends with a trailing slash, e.g /path/another/path/
# 2. will work INCORRECTLY on a path without trailing slash, e.g /path/another/path
# 3. will work with filename without suffix, e.g /path/another/file
# please note the difference of 2 and 3

# testing in irb
# >> /(.*\/)([^\/]+$)/.match(path)
# => #<MatchData "/home/user/1/2/3/4/file.txt" 1:"/home/user/1/2/3/4/" 2:"file.txt">

def separate_path_filename(str)
  # return a array, array[0] is matched string, 
  # array[1] is path, array[2] is filename
  /(.*\/)([^\/]+$)/.match(str) 
end

# more testing
=begin
path = "/home/user/1/2/3/4/file.txt" 
path2 = "/home/file.txt" 
wont_match = "/home/user/"
will_match = "/home/user" # if user is a file, then it's correct, if user is a dir, then it's wrong

r = separate_path_filename(path)
p r[0]
p r[1]
p r[2]
r = separate_path_filename(path2)
p r[0]
p r[1]
p r[2]
r = separate_path_filename(will_match)
p r[0]
p r[1]
p r[2]
r = separate_path_filename(wont_match)
p r[0]
p r[1]
p r[2]
end
