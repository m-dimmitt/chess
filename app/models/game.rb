class Game < ApplicationRecord
  belongs_to :user_black, class_name: 'User', optional: true
  belongs_to :user_white, class_name: 'User'
  has_many :pieces, dependent: :destroy
  scope :available, -> { where('user_white_id IS NULL OR user_black_id IS NULL') }

  def populate_board!
    # this should create all 32 Pieces with their initial X/Y coordinates.

    # black Pieces
    (1..8).each do |i|
      Piece.create(game_id: id, is_white: false, type: PAWN, x_position: i, y_position: 2)
    end

    Piece.create(game_id: id, is_white: false, type: ROOK, x_position: 1, y_position: 1)
    Piece.create(game_id: id, is_white: false, type: ROOK, x_position: 8, y_position: 1)

    Piece.create(game_id: id, is_white: false, type: KNIGHT, x_position: 2, y_position: 1)
    Piece.create(game_id: id, is_white: false, type: KNIGHT, x_position: 7, y_position: 1)

    Piece.create(game_id: id, is_white: false, type: BISHOP, x_position: 3, y_position: 1)
    Piece.create(game_id: id, is_white: false, type: BISHOP, x_position: 6, y_position: 1)

    Piece.create(game_id: id, is_white: false, type: KING, x_position: 4, y_position: 1)
    Piece.create(game_id: id, is_white: false, type: QUEEN, x_position: 5, y_position: 1)

    # white Pieces
    (1..8).each do |i|
      Piece.create(game_id: id, is_white: true, type: PAWN, x_position: i, y_position: 7)
    end

    Piece.create(game_id: id, is_white: true, type: ROOK, x_position: 1, y_position: 8)
    Piece.create(game_id: id, is_white: true, type: ROOK, x_position: 8, y_position: 8)

    Piece.create(game_id: id, is_white: true, type: KNIGHT, x_position: 2, y_position: 8)
    Piece.create(game_id: id, is_white: true, type: KNIGHT, x_position: 7, y_position: 8)

    Piece.create(game_id: id, is_white: true, type: BISHOP, x_position: 3, y_position: 8)
    Piece.create(game_id: id, is_white: true, type: BISHOP, x_position: 6, y_position: 8)

    Piece.create(game_id: id, is_white: true, type: KING, x_position: 5, y_position: 8)
    Piece.create(game_id: id, is_white: true, type: QUEEN, x_position: 4, y_position: 8)
  end

  def render_piece(x, y)
    piece = Piece.find_by(game_id: id, x_position: x, y_position: y)
    piece.render if piece.present?
  end

  def check?(is_white)
    king = pieces.find_by(type: KING, is_white: is_white)
    pieces.where(game_id: id, is_white: !is_white).find_each do |piece|
      return true if piece.valid_move?(king.x_position, king.y_position)
    end
    false
  end

  def forfeit_game(user_white_id)
    @game = Game.find(params[:id])
    if current_user.id == user_white_id
      @game.update_attributes(player_win: @game.user_black_id, player_lose: @game.user_white_id)
      # @user.update_attributes(games_won: games_won_update, games_played: games_played_update)
    else
      @game.update_attributes(player_win: @game.user_white_id, player_lose: @game.user_black_id)
      # @user.update_attributes(games_played: games_played_update)
    end
  end
end
