#!/usr/bin/env ruby

require 'erb'
require 'json'

include ERB::Util

def import_button(json_file_path)
  json_path = json_file_path.gsub(/^docs\//, '')

  "<a class=\"btn btn-primary btn-sm pull-right\" data-json-path=\"#{json_path}\">Import</a>"
end

def file_import_panel(json_file_path)
  title = ''
  rule_descriptions = ''

  File.open(json_file_path) do |f|
    data = JSON.parse(f.read)
    title = h(data['title'])
    data['rules'].each do |rule|
      rule_descriptions += '<div class="list-group-item">' + h(rule['description']) + '</div>'
    end
  end

  extra_description_file_path = 'src/extra_descriptions/' + json_file_path.gsub(/^docs\/json\//, '') + '.html'
  if FileTest.exist?(extra_description_file_path)
    File.open(extra_description_file_path) do |f|
      rule_descriptions += '<div class="list-group-item">' + f.read + '</div>'
    end
  end

  id = json_file_path.gsub(/^docs\/json\//, '').gsub(/.json/, '')

  <<-EOS
    <div class="panel-outer" id="#{id}">
      <div class="panel panel-default">
        <div class="panel-heading">
          <a href="##{id}"><span class="glyphicon glyphicon-link" aria-hidden="true"></span></a>
          <a class="panel-title btn btn-link" role="button" data-toggle="collapse" href="##{id}-list-group" aria-expanded="false" aria-controls="#{id}-list-group">#{title}</a>
          #{import_button(json_file_path)}
        </div>
        <div class="list-group collapse" id="#{id}-list-group">
            #{rule_descriptions}
        </div>
      </div>
    </div>
  EOS
end

def add_group(title,id,json_files)

  $toc << "\n<li class=\"list-group-item\"><span class=\"badge\">#{json_files.length}</span> \n <a href=\"##{id}\">#{title}</a></li> \n"

  group_content = ""
  json_files.each do |json|
    group_content += file_import_panel(json)
  end
  $groups += <<-EOS
      <div class="panel-outer" id="#{id}">
        <div class="panel panel-primary">
          <div class="panel-heading">
            <h3 class="panel-title">#{title}</h3>
          </div>
          <div class="panel-body">
            #{group_content}
          </div>
        </div>
      </div>
  EOS
end

def render_toc()
  toc_content = "<ul class=\"toc list-group\">"
  toc_content += "<li class=\"list-group-item list-group-item-info\">Table of Contents</li>"
  $toc.each do |toc_item|
    toc_content += toc_item
  end
  toc_content += "</ul>"
  toc_content
end

template = ERB.new $stdin.read
puts template.result
