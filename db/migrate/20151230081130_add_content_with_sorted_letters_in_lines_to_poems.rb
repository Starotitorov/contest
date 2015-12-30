class AddContentWithSortedLettersInLinesToPoems < ActiveRecord::Migration
  def change
    add_column :poems, :content_with_sorted_letters_in_lines, :text
  end
end
