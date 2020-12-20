# frozen_string_literal: true

class CreateProcedures < ActiveRecord::Migration[6.1]
  def change
    create_table :procedures do |t|
      t.string :name
      t.references :category, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :procedures }

      t.timestamps
    end
    add_index :procedures, :name, unique: true
  end
end
