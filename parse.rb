require 'json'
require 'erb'
require 'open-uri'
require 'pathname'
require 'fileutils'

default_input_dir = Pathname('./input/')
default_output_dir = Pathname('./output/')

team_name = Dir['./input/*'].first.sub(/#{default_input_dir}/, '')

input_dir = default_input_dir + team_name
output_dir = default_output_dir + team_name

FileUtils.mkdir_p(output_dir + 'images')

assets = %w(templates/bootstrap.min.css templates/simple-sidebar.css)
FileUtils.cp(assets, output_dir)

print 'import image'
users = []
open(input_dir + 'users.json') do |io|
  users = JSON.load(io).map do |user|
    File.open(output_dir + 'images' + "#{user['id']}.png", 'w') do |file|
      file.write(open(user['profile']['image_192']).read)
    end
    print '.'
    { id: user['id'], name: user['name'] }
  end
end
print "\n"

print 'parse json'
channels = []
open(input_dir + 'channels.json') do |io|
  channels = JSON.load(io).map { |channel| channel['name'] }
end

channels.each do |channel|
  File.open(output_dir + "#{channel}.html", 'w') do |file|
    file.write(ERB.new(File.read('templates/sidebar.erb')).result(binding))
    Dir[input_dir + channel + '*.json'].each do |json|
      open(json) do |io|
        messages = JSON.load(io).each do |message|
          if message['text']
            message['text'].delete!('<>')
            message['text'].gsub!(/(\r\n|\r|\n)/, '<br />')
            message['text'].gsub!(/@.{9}/) do |mention|
              user = users.find { |user| user[:id] == mention.delete('@') }
              "@#{user[:name]}" if user
            end
          end
          message[:user] = users.find { |user| user[:id] == message['user'] }
        end
        file.write(ERB.new(File.read('templates/content.erb')).result(binding))
      end
    end
  end
  print '.'
end
print "\n"
