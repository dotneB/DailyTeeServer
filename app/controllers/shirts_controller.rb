class ShirtsController < ApplicationController
  before_filter :authorize
  before_action :set_shirt, only: [:show, :edit, :update, :destroy]

  # GET /shirts
  # GET /shirts.json
  def index
    @shirts = Shirt.all
  end

  # GET /shirts/1
  # GET /shirts/1.json
  def show
  end

  # GET /shirts/new
  def new
    @shirt = Shirt.new
  end

  # GET /shirts/1/edit
  def edit
  end

  # POST /shirts
  # POST /shirts.json
  def create
    @shirt = Shirt.new(shirt_params)

    respond_to do |format|
      if @shirt.save
        format.html { redirect_to @shirt, notice: 'Shirt was successfully created.' }
        format.json { render :show, status: :created, location: @shirt }
      else
        format.html { render :new }
        format.json { render json: @shirt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shirts/1
  # PATCH/PUT /shirts/1.json
  def update
    respond_to do |format|
      if @shirt.update(shirt_params)
        format.html { redirect_to @shirt, notice: 'Shirt was successfully updated.' }
        format.json { render :show, status: :ok, location: @shirt }
      else
        format.html { render :edit }
        format.json { render json: @shirt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shirts/1
  # DELETE /shirts/1.json
  def destroy
    @shirt.destroy
    respond_to do |format|
      format.html { redirect_to shirts_url, notice: 'Shirt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shirt
      @shirt = Shirt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shirt_params
      params.require(:shirt).permit(:name, :url, :image_url, :site_id)
    end
end
