# Service similar to Penthouse for multi-tenancy. Currently it is only used to wrap
# with the account reference for use with auto scoping active record. Can be expanded
# to multi-database tenancy later.
class Switch
  CURRENT_ACCOUNT_KEY = "current_account".freeze
  THIS_ACCOUNT_KEY = "this_account".freeze

  class << self
    def current_account
      Thread.current[CURRENT_ACCOUNT_KEY]
    end

    def this_account
      Thread.current["#{THIS_ACCOUNT_KEY}_#{current_account}"] ||= Account.find_by(reference: current_account)
    end

    def account(reference, &block)
      previous_reference = Thread.current[CURRENT_ACCOUNT_KEY]
      Thread.current[CURRENT_ACCOUNT_KEY] = reference

      block.yield
    ensure
      Thread.current[CURRENT_ACCOUNT_KEY] = previous_reference
    end

    def account_list
      Account.pluck(:reference)
    end
  end
end
