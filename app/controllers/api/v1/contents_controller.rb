class Api::V1::ContentsController < ApplicationController
  include Authenticable

  before_action :set_content, only: %i[ show update destroy ]

  # GET /contents
  def index
    @contents = Content.all

    render json: Api::V1::ContentSerializer.new(@contents).serializable_hash
  end

  # GET /contents/1
  def show
    render json: Api::V1::ContentSerializer.new(@content).serializable_hash
  end

  # POST /contents
  def create
    user = @current_user
    @content = Content.new(content_params.merge(user: user))
    @content.save!

    render json: Api::V1::ContentSerializer.new(@content).serializable_hash
  end

  # PATCH/PUT /contents/1
  def update
    authorize @content
    @content.update!(content_params)
    render json: Api::V1::ContentSerializer.new(@content).serializable_hash
  end

  # DELETE /contents/1
  def destroy
    authorize @content
    @content.destroy!
    render json: { message: "Deleted" }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_content
      @content = Content.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def content_params
      params.expect(content: [ :title, :body ])
    end
end
