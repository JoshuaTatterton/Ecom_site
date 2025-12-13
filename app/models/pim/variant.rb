module Pim
  class Variant < PimRecord
    include AccountScoped

    belongs_to :product

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
