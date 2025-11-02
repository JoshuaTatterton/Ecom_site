module AccountScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :account, primary_key: :reference, foreign_key: :account_reference

    default_scope { where(account_reference: Switch.current_account) }
  end
end
