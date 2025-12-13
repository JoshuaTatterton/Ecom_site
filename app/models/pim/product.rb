module Pim
  class Product < PimRecord
    include AccountScoped

    has_many :variants, dependent: :restrict_with_error

    attr_readonly :reference

    validates :reference, presence: true, uniqueness: { scope: :account_reference }
    validates :title, presence: true
  end
end
