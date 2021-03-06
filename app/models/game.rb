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
    piece = get_piece_at_coor(x, y)
    piece.render if piece.present?
  end

  def get_piece_at_coor(x, y)
    pieces.find_by(x_position: x, y_position: y)
  end

  def check?(is_white)
    king = pieces.find_by(type: KING, is_white: is_white)
    return false if king.nil? # used for tests where there is no king generated
    pieces.where(game_id: id, is_white: !is_white).where.not(x_position: nil, y_position: nil).find_each do |piece|
      next if piece.x_position.nil? || piece.y_position.nil?
      return true if piece.valid_move?(king.x_position, king.y_position)
    end
    false
  end

  def forfeit(current_user)
    if current_user.id == user_white_id
      update_attributes!(player_win: user_black_id, player_lose: user_white_id)
    elsif current_user.id == user_black_id
      update_attributes!(player_win: user_white_id, player_lose: user_black_id)
    end
  end

  def stalemate?(is_white)
    return false if check?(is_white)
    (1..8).each do |new_x|
      (1..8).each do |new_y|
        pieces.where(is_white: is_white).where.not(x_position: nil, y_position: nil).find_each do |piece|
          return false if piece.legal_move?(new_x, new_y)
        end
      end
    end
    true
  end

  IN_PLAY = 0
  FORFEIT = 1
  CHECKMATE = 2
  STALEMATE = 3
  AGREED_DRAW = 4
end
