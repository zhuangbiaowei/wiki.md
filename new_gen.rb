require "markdown_site"

site = MarkdownSite::Site.new("./wiki.toml", :wiki)
site.copy_assets
site.write_data_json
site.generate