require 'json'
require 'erb'

class User
  attr_reader :id, :name, :image

  def initialize(id, name, image)
    @id = id
    @name = name
    @image = image
  end
end

users = []
open('./input/users.json') do |io|
  JSON.load(io).each do |user|
    users << User.new(user['id'], user['name'], user['profile']['image_192'])
  end
end

channels = []
open('./input/channels.json') do |io|
  channels = JSON.load(io).map { |channel| channel['name'] }
end

channels.each do |channel|
  File.open("./output/#{channel}.html", 'w') do |file|
    Dir["./input/#{channel}/*.json"].each do |json|
      open(json) do |io|
        messages = JSON.load(io)
        file.write(ERB.new(File.read('template.erb')).result(binding))
      end
    end
  end
end
