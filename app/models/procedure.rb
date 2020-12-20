# frozen_string_literal: true

class Procedure < ApplicationRecord
  belongs_to :category
  belongs_to :parent, class_name: 'Procedure', inverse_of: :children, optional: true
  has_many :children, inverse_of: :parent, dependent: :restrict_with_error, class_name: 'Procedure'
end
