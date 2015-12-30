class AddContentWithSortedLettersInWordsToPoems < ActiveRecord::Migration
  def change
    add_column :poems, :content_with_sorted_letters_in_words, :text
  end
end
