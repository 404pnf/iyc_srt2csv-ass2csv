class String
  def split_ass
    str = self.gsub(/\r/,"\n")
    str = str.gsub(/\n\n+/,"\n")
    str = str.gsub(/{[^}]+}/, '')
    array = str.split(/\n/)
    array = array.reject {|i|  !(i =~ /^Dialogue/) }
  end
end
