require "kramdown"
require "kramdown-parser-gfm"
require 'tomlrb'

WIKI_CONFIG = begin
    Tomlrb.load_file("wiki.toml")
rescue
    {}
end

Giscus_HTML = <<END
<script src="https://giscus.app/client.js"
        data-repo="zhuangbiaowei/wiki.md"
        data-repo-id="R_kgDOIkTcvA"
        data-category="General"
        data-category-id="DIC_kwDOIkTcvM4CTLWi"
        data-mapping="pathname"
        data-strict="0"
        data-reactions-enabled="1"
        data-emit-metadata="0"
        data-input-position="bottom"
        data-theme="light"
        data-lang="zh-CN"
        crossorigin="anonymous"
        async>
</script>
END


def get_wiki_name
    if WIKI_CONFIG.empty?
        wiki_name = ARGV.size>0 ? ARGV[0] : "My Wiki"
    else
        wiki_name = WIKI_CONFIG["wiki"]["title"]
    end
    return wiki_name
end

def get_meta_html(meta)
    meta_data = Tomlrb.parse(meta)
    html = ""
    meta_data.each do |title, values|
        html += "<p class=\"text-center bg-primary font-size-14\">"+title+"</p>\n"
        html += "<table class=\"table font-size-12\">\n"
        values.each do |key, value|
            html += "<tr>\n"
            if value.class == String
                html += "<td>"+key + "</td><td>" + value.to_s + "</td>\n"
            elsif value.class == Array
                html += "<td>"+key + "</td><td>" + value.join("<br />") + "</td>\n"
            elsif value.class == Hash
                values = ""
                value.each do |k,v|
                    values += k+"："+v+"<br />"
                end
                html += "<td>"+key + "</td><td>" + values + "</td>\n"
            end
            html += "</tr>\n"
        end
        html += "</table>\n"
    end
    return html
end

wiki_name = get_wiki_name()

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
    summary_html = Kramdown::Document.new(md, input: 'GFM').to_html
end

References = {}

files.each do |file|
    unless file=="./src/summary.md"
        text = File.read(file)
        text.gsub(/\[\[(.*)\]\]/) do |s|
            s = s[2..-3]
            item_name = file.split("/")[-1].gsub(".md","")
            if References[s]
                References[s] << item_name
            else
                References[s] = [item_name]
            end
        end
    end
end

files.each do |file|
    unless file=="./src/summary.md"
        item_name = file.split("/")[-1].gsub(".md","")
        text = File.read(file)
        md = text.gsub(/\[\[(.*)\]\]/) do |s| 
            s = s[2..-3]
            "[#{s}](#{s}.html)"
        end
        meta_html = ""
        if md.start_with?("---\n")
            mds = md.split("---\n")
            meta = mds[1]
            md = mds[2..-1].join("---\n")
            meta_html = get_meta_html(meta)
        end
        if References[item_name]
            md += "\n\n\n"
            md += "### References\n"
            References[item_name].each do |item|
                md += "* [#{item}](#{item}.html)\n"
            end
        end

        wiki_html = Kramdown::Document.new(md, input: 'GFM').to_html
        unless meta_html.empty?
            wiki_html = "<div class=\"container-fluid\" style=\"padding-top:20px\">\n" +
                        "  <div class=\"row\">\n" +
                        "    <div class=\"col-xl-8\">\n" +
                        wiki_html +
                        "    </div>\n" +
                        "    <div class=\"col-xl-3 on-this-page-nav-container shadow\" style=\"padding:10px\" >\n" +
                        meta_html.to_s +
                        "    </div>\n" +
                        "  </div>\n" +
                        "</div>"
        end
        filename = "./wiki/" + item_name + ".html"        
        if summary_html
            html = "<!DOCTYPE HTML>\n<html>"+
                   "  <head>\n"+
                   "    <meta charset=\"UTF-8\">\n"+
                   "    <link href=\"https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/css/halfmoon-variables.min.css\" rel=\"stylesheet\" />\n"+
                   "    <script src=\"https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/js/halfmoon.min.js\"></script>\n"+
                   "    <style>\n"+
                   "      ul ul {margin: 10px 0 15px 20px}\n"+
                   "      li {margin-bottom: 10px;}\n"+
                   "    </style>\n"+
                   "  </head>\n"+
                   "  <body>\n"+
                   "    <div class=\"page-wrapper with-sidebar with-navbar\">\n"+
                   "      <nav class=\"navbar\">\n"+
                   "        <a href=\"#\" class=\"navbar-brand\">"+wiki_name+"</a>\n"+
                   "      </nav>\n"+
                   "      <div class=\"sidebar\" style=\"margin-left:10px\">\n"+
                   "        <div class=\"sidebar-menu font-size-12\" style=\"margin-left:10px\">\n"+summary_html+
                   "        </div>\n"+
                   "      </div>\n"+
                   "      <div class=\"content-wrapper\" style=\"margin-left:20px\">\n"+wiki_html+"\n"+
                   Giscus_HTML +
                   "      </div>\n"+
                   "    </div>\n"+
                   "  </body>\n"+
                   "</html>"
        else
            html = "<!DOCTYPE HTML>\n<html>"+
                   "  <head>\n"+
                   "    <meta charset=\"UTF-8\">\n"+
                   "    <link href=\"https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/css/halfmoon-variables.min.css\" rel=\"stylesheet\" />\n"+
                   "    <script src=\"https://cdn.jsdelivr.net/npm/halfmoon@1.1.1/js/halfmoon.min.js\"></script>\n"+
                   "  </head>\n"+
                   "  <body>\n"+
                   "    <div class=\"page-wrapper with-navbar\">\n"+
                   "      <nav class=\"navbar\">\n"+
                   "        <a href=\"#\" class=\"navbar-brand\">"+wiki_name+"</a>\n"+
                   "      </nav>\n"+
                   "      <div class=\"content-wrapper\" style=\"margin-left:20px\">\n"+wiki_html+"\n"+
                   Giscus_HTML +
                   "      </div>\n"+
                   "    </div>\n"+
                   "  </body>\n"+
                   "</html>"
        end
        File.write(filename, html)
    end
end
