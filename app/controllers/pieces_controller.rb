class PiecesController < ApplicationController
  # def update
  #   @piece = Piece.find(params[:id])
  #   flash[:error] = @piece.errors if errors.present?
  #   redirect_to @user

  def show
    @piece = Piece.find(params[:id])
  end

  def update
    # 1,1
    # 8, 8
    piece_to_move = Piece.find(params[:id])
    piece_to_move.move_to!(params[:x_position], params[:y_position])
    # flash[:error] = 'That is an invalid move.' if piece_to_move.errors.present?
    # redirect_to game_path(piece_to_move.game)
    # render json: piece
  end
end
