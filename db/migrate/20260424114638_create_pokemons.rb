class CreatePokemons < ActiveRecord::Migration[8.1]
  def change
    create_table :pokemons do |t|
      t.string :name, null: false, index: { unique: true }, limit: 50
      
      t.timestamps
    end
  end
end
