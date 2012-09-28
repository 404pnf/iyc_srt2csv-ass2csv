
Dir.glob("./**/*").each do |file|
  File.rename(file, file.downcase) #or upcase if you want to convert to uppercase
end

# most recently modified file within a directory
Dir.glob("*").max_by {|f| File.mtime(f)}

# recursively find and remove empty directories?
Dir['**/*']                                            \
  .select { |d| File.directory? d }                    \
  .select { |d| (Dir.entries(d) - %w[ . .. ]).empty? } \
  .each   { |d| Dir.rmdir d }
