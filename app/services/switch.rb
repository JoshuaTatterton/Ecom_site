# Service similar to Penthouse for multi-tenancy. Currently it is only used to wrap
# with the account reference for use with auto scoping active record. Can be expanded
# to multi-database tenancy later.
class Switch
  CURRENT_ACCOUNT_KEY = "current_account".freeze
  CURRENT_CURRENCY_KEY = "current_currency".freeze
  THIS_ACCOUNT_KEY = "this_account".freeze

  class << self
    #####
    #
    ## Account Scoping
    #
    #####
    def current_account
      Thread.current[CURRENT_ACCOUNT_KEY]
    end

    def this_account
      Thread.current["#{THIS_ACCOUNT_KEY}_#{current_account}"] ||= Account.find_by(reference: current_account)
    end

    def account(reference, &block)
      previous_reference = Thread.current[CURRENT_ACCOUNT_KEY]
      Thread.current[CURRENT_ACCOUNT_KEY] = reference
      # Reset default currency on scoping
      Thread.current["#{CURRENT_CURRENCY_KEY}_default"] = nil

      block.yield
    ensure
      Thread.current[CURRENT_ACCOUNT_KEY] = previous_reference
    end

    def account_list
      Account.pluck(:reference)
    end

    #####
    #
    ## Currency Scoping
    #
    #####
    def current_currency
      if current_account && current_iso
        Thread.current["#{THIS_ACCOUNT_KEY}_#{current_account}_#{current_iso}"] ||= Currency.find_by(iso: current_iso)
      elsif current_account
        # Account default that is reset when unscoping from an account
        Thread.current["#{CURRENT_CURRENCY_KEY}_default"] ||= Currency.find_by(default: true)
      end
    end

    def current_iso
      Thread.current[CURRENT_CURRENCY_KEY]
    end

    def currency(iso, &block)
      previous_iso = Thread.current[CURRENT_CURRENCY_KEY]
      Thread.current[CURRENT_CURRENCY_KEY] = iso

      block.yield
    ensure
      Thread.current[CURRENT_CURRENCY_KEY] = previous_iso
    end
  end
end
