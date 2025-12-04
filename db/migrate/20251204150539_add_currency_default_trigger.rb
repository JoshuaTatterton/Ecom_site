class AddCurrencyDefaultTrigger < ActiveRecord::Migration[8.1]
  def up
    reset_default_function = <<-SQL
      CREATE OR REPLACE FUNCTION set_other_currency_default_to_false()
      RETURNS TRIGGER AS $$
      BEGIN
        UPDATE currencies
        SET
          "default" = FALSE
        WHERE account_reference = NEW.account_reference
        AND "default" = TRUE
        AND id != NEW.id;
        RETURN NEW;
      END;
      $$ LANGUAGE PLPGSQL;
    SQL

    safety_assured { execute reset_default_function }

    reset_default_trigger = <<-SQL
      CREATE OR REPLACE TRIGGER currency_default_reset_trigger
      AFTER INSERT OR UPDATE ON currencies
      FOR EACH ROW
      WHEN (NEW.default = TRUE)
      EXECUTE FUNCTION set_other_currency_default_to_false();
    SQL

    safety_assured { execute reset_default_trigger }
  end

  def down
    safety_assured { execute "DROP TRIGGER IF EXISTS currency_default_reset_trigger ON currencies;" }
    safety_assured { execute "DROP FUNCTION IF EXISTS set_other_currency_default_to_false" }
  end
end
