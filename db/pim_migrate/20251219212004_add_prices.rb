class AddPrices < ActiveRecord::Migration[8.1]
  def up
    create_table :prices do |t|
      t.string :account_reference, null: false
      t.belongs_to :variant, null: false
      t.belongs_to :currency, null: false

      t.integer :amount, null: false
      t.integer :was_amount

      t.datetime :starts_at, precision: 0, null: false
      t.datetime :ends_at, precision: 0, null: false
      # Use tsrange instead of tstzrange. To store without timezone
      # as the stored dates should always be UTC
      t.tsrange :active_during

      t.timestamps
    end

    active_during_function = <<-SQL
      CREATE OR REPLACE FUNCTION maintain_price_active_during()
      RETURNS TRIGGER AS $$
      BEGIN
        UPDATE prices
        SET
          active_during = tsrange(NEW.starts_at, NEW.ends_at, '[]')
        WHERE id = NEW.id;
        RETURN NEW;
      END;
      $$ LANGUAGE PLPGSQL;
    SQL

    safety_assured { execute active_during_function }

    price_create_active_trigger = <<-SQL
      CREATE OR REPLACE TRIGGER price_create_active_trigger
      AFTER INSERT ON prices
      FOR EACH ROW
      EXECUTE FUNCTION maintain_price_active_during();
    SQL

    price_update_active_trigger = <<-SQL
      CREATE OR REPLACE TRIGGER price_update_active_trigger
      AFTER UPDATE ON prices
      FOR EACH ROW
      WHEN ( OLD.starts_at != NEW.starts_at OR OLD.starts_at != NEW.starts_at)
      EXECUTE FUNCTION maintain_price_active_during();
    SQL

    safety_assured { execute price_create_active_trigger }
    safety_assured { execute price_update_active_trigger }
  end

  def down
    safety_assured { execute "DROP TRIGGER IF EXISTS price_update_active_trigger ON prices;" }
    safety_assured { execute "DROP TRIGGER IF EXISTS price_create_active_trigger ON prices;" }
    safety_assured { execute "DROP FUNCTION IF EXISTS maintain_price_active_during" }

    drop_table :prices
  end
end
