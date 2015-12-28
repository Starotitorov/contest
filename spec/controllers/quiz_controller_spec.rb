require 'rails_helper'

RSpec.describe QuizController, type: :controller do
  describe "#registration" do
    before { FactoryGirl.create(:poem).save }
    it "should complete registration" do
      amount_of_tokens_before = Token.count
      post :registration,
            token: 'abcdefg', question: "Буря мглою небо кроет, Вихри %WORD% крутя",
            format: :json
      expect(Token.count - amount_of_tokens_before).to eq 1
      expect(Token.last.value).to eq 'abcdefg'
      answer = JSON.parse(response.body)["answer"]
      expect(answer).to eq("снежные")
    end
  end

  describe "#answer" do
    before do
      FactoryGirl.create(:poem, title: "К Чаадаеву", 
      content: "Любви, надежды, тихой славы\nНедолго нежил нас обман,\nИсчезли юные забавы,\nКак сон, как утренний туман;\nНо в нас горит еще желанье,\nПод гнетом власти роковой\nНетерпеливою душой\nОтчизны внемлем призыванье.\nМы ждем с томленьем упованья\nМинуты вольности святой,\nКак ждет любовник молодой\nМинуты верного свиданья.\nПока свободою горим,\nПока сердца для чести живы,\nМой друг, отчизне посвятим\nДуши прекрасные порывы!\nТоварищ, верь: взойдет она,\nЗвезда пленительного счастья,\nРоссия вспрянет ото сна,\nИ на обломках самовластья\nНапишут наши имена!\n").save
      Token.create(value: 'abcdefg')
    end
    it "should give right answer on question level 1" do 
      post :answer, question: "Отчизны внемлем призыванье", id: 1, level: 1,
            format: :json
      answer = JSON.parse(response.body)["answer"]
      expect(answer).to eq("К Чаадаеву")
    end
    it "should give right answer on question level 2" do
      post :answer, question: "Отчизны внемлем %WORD%", id: 2, level: 2,
            format: :json
      answer = JSON.parse(response.body)["answer"]
      expect(answer).to eq("призыванье")
    end
    it "should give right answer on question level 3" do
      post :answer, question: "Звезда пленительного %WORD%,\nРоссия %WORD% ото сна", id: 3, level: 3,
            format: :json
      answer = JSON.parse(response.body)["answer"]
      expect(answer).to eq("счастья,вспрянет")
    end
    it "should give right answer on question level 4" do
      post :answer, question: "%WORD% друг, отчизне посвятим\nДуши прекрасные %WORD%!\nТоварищ, %WORD%: взойдет она,", id: 3, level: 4,
            format: :json
      answer = JSON.parse(response.body)["answer"]
      expect(answer).to eq("Мой,порывы,верь")
    end
    it "should give right answer on question level 4" do
      post :answer, question: "Души прекрасные надежды!", id: 4, level: 5,
            format: :json
      answer = JSON.parse(response.body)["answer"]
      expect(answer).to eq("порывы,надежды")
    end
  end

end
