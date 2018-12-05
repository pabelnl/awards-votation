class AddJugadorNuncaToVoter < ActiveRecord::Migration[5.2]
  def change
    add_column :voters, :jugador, :string
    add_column :voters, :nunca, :string
  end
end
