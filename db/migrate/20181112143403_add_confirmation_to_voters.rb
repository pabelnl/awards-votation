class AddConfirmationToVoters < ActiveRecord::Migration[5.2]
  def change
    add_column :voters, :confirmation_token, :string
    add_column :voters, :confirmed, :boolean
  end
end
