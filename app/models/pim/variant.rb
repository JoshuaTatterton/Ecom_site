module Pim
  class Variant < PimRecord
    include AccountScoped

    belongs_to :product
    has_many :prices, -> { order(starts_at: :asc, ends_at: :asc, amount: :asc) }
    has_one :active_price, -> {
      where("active_during @> NOW()::timestamp")
      .where(currency: Switch.current_currency)
      .order(starts_at: :asc, ends_at: :asc, amount: :asc)
    }, class_name: "Pim::Price"

    attr_readonly :reference

    validates :reference, presence: true, uniqueness: { scope: :account_reference }
    validates :title, presence: true
    validates :position, presence: true,
      numericality: { only_integer: true, greater_than_or_equal_to: 0 },
      allow_blank: true

    before_validation :set_default_position

    private

    def set_default_position
      self.position ||= product&.variants&.count || 0
    end
  end
end
