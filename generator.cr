require "markd"

unless Dir.exists?("./wiki")
    Dir.mkdir("wiki")
end

files = Dir.glob("./src/*.md")

if File.exists?("./src/summary.md")
    summary = File.read("./src/summary.md")
    md = summary.gsub(/\[\[(.*)\]\]/) do |s|
        s = s[2..-3]
        "[#{s}](#{s}.html)"
    end
    summary_html = Markd.to_html(md)
end

files.each do |file|
    unless file=="./src/summary.md"
        text = File.read(file)
        md = text.gsub(/\[\[(.*)\]\]/) do |s| 
            s = s[2..-3]
            "[#{s}](#{s}.html)"
        end
        wiki_html = Markd.to_html(md)
        filename = file.split("/")[-1].gsub(".md"){".html"}
        if summary_html
            html = "<!DOCTYPE HTML>\n<html>"+
                   "  <head>\n"+
                   "  <meta charset=\"UTF-8\">\n"+
                   "  <link rel=\"stylesheet\" href=\"layout.css\">\n"+
                   "  </head>\n"+
                   "  <body>\n"+
                   "    <div class=\"sidebar\">"+summary_html+"</div>\n"+
                   "    <div class=\"content\">"+wiki_html+"</div>\n"+
                   "  </body>\n"+
                   "</html>"
        else
            html = wiki_html
        end
        File.write("./wiki/"+filename, html)
    end
end


File.write "./wiki/layout.css", <<-STR
.sidebar {
    float: left;
    width: 200px;
    background-color: rgb(230, 230, 230);
    height: 800px;
}

.content {
    margin-left: 210px;
}
STR