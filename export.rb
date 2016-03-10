require 'json'
require 'erb'
require 'open-uri'

users = []
open('./input/users.json') do |io|
  JSON.load(io).each do |user|
    File.open("./output/images/#{user['id']}.png", 'w') do |file|
      file.write(open(user['profile']['image_192']).read)
    end
    users << { id: user['id'], name: user['name'] }
  end
end

channels = []
open('./input/channels.json') do |io|
  channels = JSON.load(io).map { |channel| channel['name'] }
end

channels.each do |channel|
  File.open("./output/#{channel}.html", 'w') do |file|
    file.write(ERB.new(File.read('templates/sidebar.erb')).result(binding))
    Dir["./input/#{channel}/*.json"].each do |json|
      open(json) do |io|
        messages = JSON.load(io)
        file.write(ERB.new(File.read('templates/content.erb')).result(binding))
      end
    end
  end
end
