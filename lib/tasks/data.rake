require 'mechanize'
require 'colorize'

namespace :db do
  desc "Fill database with data"
  task populate: :environment do
    agent = Mechanize.new
    agent.get('http://ilibrary.ru/author/pushkin/l.all/index.html')
    links = agent.page.parser.css('#text .list a')
    link = links.first
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
      array_of_lines_with_sorted_letters = []
      array_of_lines_with_sorted_letters_in_words = []
      text.split("\n").each do |line|
        line.delete! '.,!?:;()—'
        array_of_words_with_sorted_letters = line.mb_chars.downcase.split
        array_of_words_with_sorted_letters.each_index do |ind|
          array_of_words_with_sorted_letters[ind] =
              array_of_words_with_sorted_letters[ind].chars.sort.join
        end
        array_of_lines_with_sorted_letters_in_words.
            push array_of_words_with_sorted_letters.join(" ")
        new_line = line.mb_chars.downcase.chars.sort.join
        array_of_lines_with_sorted_letters.push new_line
      end
      poem.content_with_sorted_letters_in_lines =
          array_of_lines_with_sorted_letters.join("\n")
      poem.content_with_sorted_letters_in_words =
        array_of_lines_with_sorted_letters_in_words.join("\n")    
      poem.save
    end
  end
end
