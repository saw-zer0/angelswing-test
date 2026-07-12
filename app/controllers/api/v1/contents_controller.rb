class Api::V1::ContentsController < ApplicationController
  include Authenticable

  before_action :set_content, only: %i[ show update destroy ]

  # GET /contents
  def index
    @contents = Content.all

    render json: @contents
  end

  # GET /contents/1
  def show
    render json: @content
  end

  # POST /contents
  def create
    user = @current_user
    @content = Content.new(content_params.merge(user: user))

    if @content.save
      render json: Api::V1::ContentSerializer.new(@content).serializable_hash.to_json
    else
      render json: @content.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /contents/1
  def update
    if @content.update(content_params)
      render json: @content
    else
      render json: @content.errors, status: :unprocessable_content
    end
  end

  # DELETE /contents/1
  def destroy
    @content.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_content
      @content = Content.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def content_params
      params.expect(content: [ :title, :body, :user_id ])
    end
end
