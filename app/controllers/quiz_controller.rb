class QuizController < ApplicationController
  skip_before_action :verify_authenticity_token

  def home
    render json: {text: "Pushkin contest"}
  end

  def answer
  end
  
  def registration
    token = params[:token]
    question = params[:question]
    data = YAML.load_file("#{Rails.root}/config/token.yml")
    data[Rails.env]['USER_TOKEN'] = token
    File.open("#{Rails.root}/config/token.yml", 'w') { |f| YAML.dump(data, f) }
    answer = 'снежные'
    render json: {answer: answer}
  end

  private

  def find_answer_on_question_level_2(line)
    splited = line.partition '%WORD%'
    text = find_poem_with_replaced_word(splited).try :content
    find_replaced_word_in_poem(text, splited)
  end

  def find_poem_with_replaced_word(splited)
    Poem.where('content ~* ?', splited[0] + '[А-Яа-я]*' + splited[2]).first
  end

  def find_replaced_word_in_poem(text, splited)
    if splited[0].empty?
      text.split(splited[2])[0].split(/\s|"|\(/)[-1] if text
    elsif splited[2].empty?
      text.split(splited[0])[1].split(/\s|,|\.|\?|!|:|;|\(|\)|"/)[0] if text
    else
      text.split(splited[0])[1].split(splited[2])[0] if text   
    end
  end
end
