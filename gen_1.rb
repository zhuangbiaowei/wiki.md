require "markdown_extension"
require "liquid"
require "json"

site = MarkdownExtension::Site.new("./wiki.toml", :wiki)
site_name = site.config.title ? site.config.title : "My Wiki"
unless Dir.exist?("./wiki")
    Dir.mkdir("wiki")
end

site.write_data_json("./wiki/data.json")

default_path = site.config.languages.first[0]

unless Dir.exist?("./wiki/#{default_path}")
    Dir.mkdir("wiki/#{default_path}")
end

root_template = Liquid::Template.parse(File.read("./template/root.liquid"))
f = File.new("./wiki/index.html", "w")
f.puts root_template.render(
    'url'=>"#{default_path}/index.html"
)
f.close

default_lang = site.config.languages.first[1]
languages = []
site.config.languages.each do |k, v|
    languages << {"path"=>k, "title"=>v}
end
index_template = Liquid::Template.parse(File.read("./template/index.liquid"))
f = File.new("./wiki/#{default_path}/index.html", "w")
f.puts index_template.render(
        'config' =>{'title'=>site_name},
        'default_lang'=>default_lang,
        'languages' => languages,
        'summary'=> "Hello")
f.close

`cp tree.js ./wiki/#{default_path}/tree.js`
