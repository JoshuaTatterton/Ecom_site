module Pim
  class Variant < PimRecord
    include AccountScoped

    belongs_to :product

    attr_readonly :reference

    validates :reference, presence: true, uniqueness: { scope: :account_reference }
    validates :title, presence: true
  end
end
