# frozen_string_literal: true

class Procedure < ApplicationRecord
  belongs_to :parent, polymorphic: true
  has_many :children, as: :parent, class_name: 'Procedure', dependent: :restrict_with_error
end
