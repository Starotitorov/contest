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
    else
      answer = nil
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
    words = question.split(' ')
    words.each do |word|
      new_question = question.sub word, '%WORD%'
      answer = find_missed_words new_question
      unless answer.empty?
        answer.delete! '.,!?:;()'
        word.delete! '.,!?:;()'
        return "#{answer},#{word}"
      end
    end
  end

  def find_out_title_of_the_poem(question)
    Poem.where("content ~* ?", question).first.try :title
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
    Poem.where('content ~* ?', parts[0] + '[А-Яа-я]*' + parts[2]).first
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
