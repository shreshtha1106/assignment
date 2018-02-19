class CreateDeliveryExecutives < ActiveRecord::Migration
  def change
    create_table :delivery_executives do |t|

      t.timestamps null: false
    end
  end
end
