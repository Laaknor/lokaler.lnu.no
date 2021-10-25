# frozen_string_literal: true

class AggregatedFacilityReview < ApplicationRecord
  enum experience: { unknown: 0, impossible: 1, unlikely: 2, maybe: 3, likely: 4 }
  belongs_to :facility
  belongs_to :space
end
