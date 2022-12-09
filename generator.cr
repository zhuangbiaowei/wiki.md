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
                   "    <meta charset=\"UTF-8\">\n"+
                   "    <link href=\"https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/css/halfmoon-variables.min.css\" rel=\"stylesheet\" />\n"+
                   "    <script src=\"https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/js/halfmoon.min.js\"></script>\n"+
                   "  </head>\n"+
                   "  <body>\n"+
                   "    <div class=\"page-wrapper with-sidebar\">\n"+
                   "      <div class=\"sidebar\" style=\"margin-left:10px\">\n"+
                   "        <div class=\"sidebar-menu\">\n"+summary_html+
                   "        </div>\n"+
                   "      </div>\n"+                   
                   "      <div class=\"content-wrapper\" style=\"margin-left:20px\">"+wiki_html+"</div>\n"+
                   "    </div>\n"+
                   "  </body>\n"+
                   "</html>"
        else
            html = wiki_html
        end
        File.write("./wiki/"+filename, html)
    end
end