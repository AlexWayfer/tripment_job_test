# frozen_string_literal: true

class CreateProcedures < ActiveRecord::Migration[6.1]
  def change
    create_table :procedures do |t|
      t.string :name
      t.references :parent, polymorphic: true, null: false

      t.timestamps
    end
    add_index :procedures, :name, unique: true
  end
end
