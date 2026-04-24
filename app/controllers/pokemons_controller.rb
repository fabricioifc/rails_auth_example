class PokemonsController < ApplicationController
  before_action :set_pokemon, only: [:edit, :update, :destroy]

  def index
    @pokemons = Pokemon.order(:name)
    @pokemon = Pokemon.new
  end

  def create
    @pokemon = Pokemon.new(pokemon_params)

    if @pokemon.save
      respond_to do |format|
        format.html { redirect_to pokemons_path }
        format.turbo_stream
      end
    else
      render :index
    end
  end

  def edit
  end

  def update
    if @pokemon.update(pokemon_params)
      respond_to do |format|
        format.html { redirect_to pokemons_path }
        format.turbo_stream
      end
    else
      render :edit
    end
  end

  def destroy
    @pokemon.destroy

    respond_to do |format|
      format.html { redirect_to pokemons_path }
      format.turbo_stream
    end
  end

  private

  def set_pokemon
    @pokemon = Pokemon.find(params[:id])
  end

  def pokemon_params
    params.require(:pokemon).permit(:name)
  end
end