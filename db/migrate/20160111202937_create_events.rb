class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :action
      t.string :user
      t.string :otheruser
      t.string :message
      t.datetime :date

      t.timestamps null: false
    end
  end
end
