class AddPriceIndexes < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :prices,
      [ :variant_id, :starts_at, :ends_at ],
      name: "price_ordering_index",
      algorithm: :concurrently

    add_index :prices,
      [ :variant_id, :active_during ],
      name: "active_price_index",
      algorithm: :concurrently

    add_index :prices,
      [ :variant_id, :was_amount ],
      name: "discounted_price_index",
      algorithm: :concurrently
  end
end
