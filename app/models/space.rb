# frozen_string_literal: true

class Space < ApplicationRecord
  has_paper_trail

  has_many :facilities, dependent: :restrict_with_exception
  has_many :reviews, dependent: :restrict_with_exception

  belongs_to :space_owner
  belongs_to :space_type

  has_rich_text :how_to_book
  has_rich_text :who_can_use
  has_rich_text :pricing
  has_rich_text :terms
  has_rich_text :more_info
end
