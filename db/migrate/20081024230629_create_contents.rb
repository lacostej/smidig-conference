class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :contents
  end
end
