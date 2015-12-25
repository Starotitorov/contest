require 'mechanize'
require 'colorize'

namespace :db do
  desc "Fill database with data"
  task populate: :environment do
    agent = Mechanize.new
    agent.get('http://ilibrary.ru/author/pushkin/l.all/index.html')
    links = agent.page.parser.css('#text .list a')
    links.each do |link|
      agent.click(link)
      agent.page.link_with(text: 'Читать онлайн  →').click
      title = agent.page.parser.css('.title h1').text
      text = agent.page.parser.css('.poem_main').text
      text.gsub!(/\u0097/, "\u2014")
      text.gsub!(/^\n/, "")
      puts title.red
      puts text.green
      next if text.empty?
      poem = Poem.new
      poem.title = title
      poem.content = text
      poem.save
    end
  end
end
