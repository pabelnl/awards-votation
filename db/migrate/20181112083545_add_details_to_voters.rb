class AddDetailsToVoters < ActiveRecord::Migration[5.2]
  def change
    add_column :voters, :email, :string
    add_column :voters, :mmgvo, :string
    add_column :voters, :revelacion, :string
    add_column :voters, :infeliz, :string
  end
end
