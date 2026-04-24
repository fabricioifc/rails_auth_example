class PokemonsController < ApplicationController
  def index
    @pokemons = Pokemon.order(:name)
  end

  def create
    @pokemon = Pokemon.new(pokemon_params)
    if @pokemon.save
      redirect_to pokemons_path, notice: "Pokemon created successfully."
    else
      redirect_to pokemons_path, alert: "Failed to create Pokemon: #{@pokemon.errors.full_messages.join(', ')}"
    end
  end

  private

  def pokemon_params
    params.require(:pokemon).permit(:name)
  end
end
