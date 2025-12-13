class AddVariantsPositionTrigger < ActiveRecord::Migration[8.1]
  def up
    increase_positions_function = <<-SQL
      CREATE OR REPLACE FUNCTION increase_duplicate_variant_positions()
      RETURNS TRIGGER AS $$
      BEGIN
        IF
          OLD.position IS DISTINCT FROM NEW.position
        AND
          EXISTS (
            select 1
            FROM variants
            WHERE product_id = NEW.product_id
            AND position = NEW.position
            AND id != NEW.id
            LIMIT 1
          )
        THEN
          UPDATE variants
          SET
            position = position + 1
          WHERE product_id = NEW.product_id
          AND position >= NEW.position
          AND id != NEW.id;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE PLPGSQL;
    SQL

    safety_assured { execute increase_positions_function }

    # Trigger function when position changes AND record exists on the new position.
    # Use the limit to try prevent it having to look through the whole table as
    # soon as it finds 1 record.
    increase_positions_trigger = <<-SQL
      CREATE OR REPLACE TRIGGER variants_position_clash_trigger
      AFTER INSERT OR UPDATE ON variants
      FOR EACH ROW
      EXECUTE FUNCTION increase_duplicate_variant_positions();
    SQL

    safety_assured { execute increase_positions_trigger }
  end

  def down
    safety_assured { execute "DROP TRIGGER IF EXISTS variants_position_clash_trigger ON variants;" }
    safety_assured { execute "DROP FUNCTION IF EXISTS increase_duplicate_variant_positions" }
  end
end
