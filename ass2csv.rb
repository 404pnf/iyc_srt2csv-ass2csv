# -*- coding: utf-8 -*-
require './lib/script2csv.rb'
$input = File.expand_path(ARGV[0])
$output = File.expand_path(ARGV[1])
def ass2csv(file)
  input = split_ass(File.read(file))
  file_with_bom
  write_to_file(generate_hash(input))
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
    next unless file =~ /ass$/i
    next if File.directory?(file)
    $inputfile = File.basename(file, 'ass') # $inputfile is filename. , with a dot
    $inputpath = File.dirname(file)
    $newpath = $inputpath.sub(input, output)
    puts "正在处理： #{file}"
    puts ""
    ass2csv(file) # defined in lib/script2csv.rb
  end
  ending_msg
end
r_ass2csv($input, $output)
