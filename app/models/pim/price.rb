module Pim
  class Price < PimRecord
    include AccountScoped

    belongs_to :variant
    belongs_to :currency

    validates :amount, presence: true
    validates :was_amount, numericality: { greater_than: :amount, allow_blank: true }
    validates :starts_at, presence: true
    validates :ends_at, presence: true, comparison: { greater_than: :starts_at }

    normalizes :starts_at, with: ->starts_at { starts_at.beginning_of_minute }
    normalizes :ends_at, with: ->ends_at { ends_at.beginning_of_minute }
  end
end
