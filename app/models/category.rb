# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :children, as: :parent, class_name: 'Procedure', dependent: :restrict_with_error
end
