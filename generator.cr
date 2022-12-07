require "markd"

unless Dir.exists?("./wiki")
    Dir.mkdir("wiki")
end

files = Dir.glob("./src/*.md")

files.each do |file|
    text = File.read(file)
    md = text.gsub(/\[\[(.*)\]\]/) do |s| 
       s = s[2..-3] 
       "[#{s}](#{s}.html)" 
    end
    html = Markd.to_html(md)
    filename = file.split("/")[-1].gsub(".md"){".html"}    
    File.write("./wiki/"+filename, html)    
end