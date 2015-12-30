module FactoryHelpers
  extend self

  def build_content_with_sorted_letters_in_lines(text)
    array_of_lines_with_sorted_letters = []
    text.split("\n").each do |line|
      line.delete! '.,!?:;()—'
      new_line = line.mb_chars.downcase.chars.sort.join
      array_of_lines_with_sorted_letters.push new_line
    end
    array_of_lines_with_sorted_letters.join("\n")
  end

  def build_content_with_sorted_letters_in_words(text)
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
    end
    array_of_lines_with_sorted_letters_in_words.join("\n")
  end
end

FactoryGirl.define do  
  factory :poem do
    title 'ДОБРЫЙ ЧЕЛОВЕК'
    content "Ты прав — несносен Фирс ученый,\nПедант надутый и мудреный —\nОн важно судит обо всем,\nВсего он знает понемногу.\nЛюблю тебя, сосед Пахом, —\nТы просто глуп, и слава богу.\n"
    content_with_sorted_letters_in_lines { FactoryHelpers.build_content_with_sorted_letters_in_lines content }
    content_with_sorted_letters_in_words { FactoryHelpers.build_content_with_sorted_letters_in_words content }
  end
end
