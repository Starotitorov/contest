class QuizController < ApplicationController
  skip_before_action :verify_authenticity_token

  def home
    render json: {text: "Pushkin contest"}
  end

  def answer
    level = params[:level]
    question = params[:question]
    id = params[:id]
    level_str = level.to_s
    case level_str
    when '1'
      answer = find_out_title_of_the_poem question
    when '2'..'4'
      answer = find_missed_words question
    when '5'
      answer = find_correct_and_wrong_word question
    when '6'
      answer = find_line_with_correct_order_of_letters_in_words question
    when '7'
      answer = find_line_with_correct_order_of_letters question
    when '8'
      answer = find_line_with_replaced_letter_and_correct_order_of_letters question
    else
      answer = "Unknown level"
    end
    send_answer answer, id
    render json: {
      answer: answer,
      token: Token.last.value,
      task_id: id
    }
  end
  
  def registration
    value = params[:token]
    question = params[:question]
    token = Token.new
    token.value = value
    token.save
    answer = 'снежные'
    render json: {answer: answer}
  end

  private

  URI = URI("http://pushkin.rubyroid.by/quiz")

  def send_answer(answer, id)
    parameters = {
      answer: answer,
      token: Token.last.value,
      task_id: id
    }
    Net::HTTP.post_form(URI, parameters)
  end

  def find_correct_and_wrong_word(question)
    words = question.split
    words.each do |word|
      new_question = question.sub word, '%WORD%'
      answer = find_missed_words new_question
      unless answer.empty?
        answer.delete! '.,!?:;()—'
        word.delete! '.,!?:;()—'
        return "#{answer},#{word}"
      end
    end
  end

  def find_out_title_of_the_poem(question)
    Poem.find_by("content ~* ?", question).try :title
  end

  def find_missed_words(question)
    answer = []
    lines = question.split("\n")
    parts_of_first_line = lines[0].partition '%WORD%'
    text = find_poem_with_missed_word(parts_of_first_line).try :content
    unless text
      return ""
    end
    answer.push find_missed_word_in_poem(text, parts_of_first_line)
    lines.drop(1).each do |line|
      parts = line.partition '%WORD%'
      answer.push find_missed_word_in_poem(text, parts)
    end
    answer.join(',')
  end

  def find_poem_with_missed_word(parts)
    Poem.find_by('content ~* ?', parts[0] + '[А-Яа-я]*' + parts[2])
  end

  def find_line_with_correct_order_of_letters_in_words(question)
    new_question = question.mb_chars.downcase.chars.sort.join
    poem = Poem.find_by("content_with_sorted_letters_in_lines ~* ?", new_question)
    text = poem.content
    text_with_sorted_letters_in_lines=poem.content_with_sorted_letters_in_lines
    index = text_with_sorted_letters_in_lines.split("\n").index(new_question)
    text.split("\n")[index].delete! '.,!?:;()—'
    #new_question = question.mb_chars.downcase.to_s
    #words_with_incorrect_order_of_letters = new_question.split
    #words_with_incorrect_order_of_letters.each_index do |ind|
    #  words_with_incorrect_order_of_letters[ind] =
    #      words_with_incorrect_order_of_letters[ind].chars.sort.join
    #end
    #required_line = words_with_incorrect_order_of_letters.join(" ")
    #poem = Poem.find_by("content_with_sorted_letters_in_words ~* ?",
    #    required_line)
    #text = poem.content
    #text_with_sorted_letters_in_words =poem.content_with_sorted_letters_in_words
    #index = text_with_sorted_letters_in_words.split("\n").index(required_line)
    #text.split("\n")[index].delete! '.,!?:;()—'
    #text.split("\n").each do |line|
    #  line.delete! '.,!?:;()—'
    #  new_line = line.mb_chars.downcase.to_s
    #  words = new_line.split
    #  words.each_index do |ind|
    #    words[ind] = words[ind].chars.sort.join
    #  end
    #  if words.join(" ") == required_line
    #    return line
    #  end
    #end
    #Poem.find_each(batch_size: 100) do |poem|
    #  poem.content.split("\n").each do |line|
    #    line.delete! '.,!?:;()—'
    #    new_line = line.mb_chars.downcase.to_s
    #    words = new_line.split
    #    words.each_index do |ind|
    #      words[ind] = words[ind].chars.sort.join
    #      if words[ind] != words_with_incorrect_order_of_letters[ind]
    #        break
    #      end
    #    end
    #    if words == words_with_incorrect_order_of_letters
    #      return line
    #    end
    #  end
    #end
  end

  def find_line_with_correct_order_of_letters(question)
    new_question = question.mb_chars.downcase.chars.sort.join
    poem = Poem.find_by("content_with_sorted_letters_in_lines ~* ?", new_question)
    text = poem.content
    text_with_sorted_letters_in_lines=poem.content_with_sorted_letters_in_lines
    index = text_with_sorted_letters_in_lines.split("\n").index(new_question)
    text.split("\n")[index].delete! '.,!?:;()—'
    #text.split("\n").each do |line|
    #  line.delete! '.,!?:;()—'
    #  new_line = line.mb_chars.downcase.chars.sort.join
    #  if new_line == new_question
    #    return line
    #  end
    #end
    #Poem.find_each(batch_size: 100) do |poem|
    #  poem.content.split("\n").each do |line|
    #    line.delete! '.,!?:;()—'
    #    if line.length != question.length
    #      next
    #    end
    #    new_line = line.mb_chars.downcase.chars.sort.join
    #    if new_line == new_question
    #      return line
    #    end
    #  end
    #end
  end

  def find_line_with_replaced_letter_and_correct_order_of_letters(question)
    hash_of_letters_in_question = Hash.new(0)
    question.mb_chars.downcase.chars.each do |letter|
      hash_of_letters_in_question[letter] += 1
    end
    Poem.find_each(batch_size: 1000) do |poem|
      poem.content.split("\n").each do |line|
        line.delete! '.,!?:;()—'
        if line.length != question.length
          next
        end
        new_line = line.mb_chars.downcase.to_s
        hash_of_letters_in_line = Hash.new(0)
        new_line.chars.each { |letter| hash_of_letters_in_line[letter] += 1 }
        arr = hash_of_letters_in_line.to_a - hash_of_letters_in_question.to_a
        if arr.count < 3
          flag = true
          arr.each do |a|
            if (a[1] - hash_of_letters_in_question[a[0]]).abs > 1 && arr.length == 2
              flag = false
              break
            end
            if (a[1] - hash_of_letters_in_question[a[0]]).abs > 2 && arr.length == 1
              flag = false
              break
            end
          end
          if flag
            return line
          end
        end
      end
    end
  end

  def find_missed_word_in_poem(content, parts)
    if parts[0].empty?
      content.split(parts[2])[0].split(/\s|"|\(/)[-1] if content
    elsif parts[2].empty?
      content.split(parts[0])[1].split(/\s|,|\.|\?|!|:|;|\(|\)|"/)[0] if content
    else
      content.split(parts[0])[1].split(parts[2])[0] if content
    end
  end
end
