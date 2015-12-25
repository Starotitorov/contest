require 'rails_helper'

RSpec.describe QuizController, type: :controller do

  before { FactoryGirl.create(:poem).save }
  describe "#registration" do
    it "should complete registration" do
      post :registration,
            token: 'abcdefg', question: 'Ты прав — несносен %WORD% ученый,',
            format: :json
      answer = JSON.parse(response.body)["answer"]
      expect(answer).to eq('Фирс')
    end
  end

end
