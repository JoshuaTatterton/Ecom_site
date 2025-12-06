class Currency < ApplicationRecord
  include AccountScoped

  validates :iso, presence: true,
    uniqueness: { scope: :account_reference },
    inclusion: { in: CurrencyHelper::CURRENCY_ISOS }
  validates :name, presence: true
  validates :code, presence: true
  validates :symbol, presence: true
  validates :decimals, presence: true
  validate :valid_currency_configuration

  private

  def valid_currency_configuration
    # Exit if already invalid because of iso inclusion
    return unless CurrencyHelper::CURRENCY_ISOS.include?(iso)

    currency_config = CurrencyHelper::CURRENCIES[iso]
    # If any config attribute does not match the currency add error
    if currency_config.any? { |key, value| attributes[key.to_s] != value }
      errors.add(:base, :invalid_currency)
    end
  end
end
