require 'dxopal'
include DXOpal

Window.width = 900
Window.height = 600
Window.loop do
  Window.draw_font(0, 0, 'now loading...', Font.default, color: C_WHITE)
end

['spade', 'heart', 'dia', 'clover'].each do |suit|
  [*1..13].each do |number|
    name = "#{suit}_#{number}"
    Image.register(name.to_sym, "images/#{name}.png")
  end
end
Image.register(:face_down_card, "images/face_down_card.png")

module Dragable
  def move_to_front!
    @@max_z = 0 if @@max_z.nil?
    @@max_z += 1
    self.z = @@max_z
  end

  def click?
    hover? && Input.mouse_push?(M_LBUTTON)
  end

  def hover?
    x1 = self.x
    x2 = self.x + self.image.width
    mx = Input.mouse_x
    y1 = self.y
    y2 = self.y + self.image.height
    my = Input.mouse_y

    (x1..x2).cover?(mx) && (y1..y2).cover?(my)
    end

  def update
    if hover? && Input.mouse_down?(M_LBUTTON) && @@target_id.nil?
      @@target_id = self.__id__
      @@diff_x = Input.mouse_x - self.x + 4
      @@diff_y = Input.mouse_y - self.y + 4
      @@orig_x = self.x
      @@orig_y = self.y
      @@orig_angle = self.angle
      move_to_front!
    end

    if Input.mouse_down?(M_LBUTTON) && @@target_id == self.__id__
      self.x = Input.mouse_x - @@diff_x
      self.y = Input.mouse_y - @@diff_y
      self.angle = 0
    end

    if Input.mouse_release?(M_LBUTTON) && @@target_id == self.__id__
      @@target_id = nil
      self.x = @@orig_x
      self.y = @@orig_y
      self.angle = @@orig_angle
    end
  end
end

class Card < Sprite
  include Dragable
  attr_reader :suit, :number, :score

  SUIT_TABLE = {
    spade: '♠', heart: '♥', dia: '♦', clover: '♣'
  }
  NUM_TABLE = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']

  def initialize(s, n)
    @suit = s
    @number = n
    super(752, 200, Image[:"#{@suit}_#{@number}"])

    @score = calc_score
    to_face_down!
    self.collision_sync = true
    self.collision = [0, 0, self.image.width, self.image.height]
  end

#  def update
#    super
#  end

  def shot(other)
    to_face_down!
  end

  def hit(other)
  end

  def to_face_up!
    @face_up = true
    self.image = Image[:"#{@suit}_#{@number}"]
  end

  def to_face_down!
    @face_up = false
    self.image = Image[:face_down_card]
  end

  def face_up?
    @face_up
  end

  def face_down?
    !face_up?
  end

  def to_s
    "#{SUIT_TABLE[suit]}#{NUM_TABLE[number]}"
  end

  private

  def calc_score
    number.clamp(1, 10)
  end
end

class Deck
  attr_reader :cards

  def initialize
    create_new_deck!
    shuffle!
  end

  def create_new_deck!
    suits = Card::SUIT_TABLE.keys
    numbers = [*1..13]
    @cards = suits.product(numbers).map { |s, n| Card.new(s, n) }
  end

  def shuffle!
    @cards = cards.shuffle
  end
end

class Common
end

Window.load_resources do
  deck = Deck.new

  cards = deck.cards.dup
  cards.map do |card|
    card.scale_x = 0.9
    card.scale_y = 0.9
    card.move_to_front!
    card
  end

  i = 0
  common_cards = deck.cards.pop(4).map do |card|
    card.x = 16 + (card.image.width + 16) * i
    card.scale_x = 0.9
    card.scale_y = 0.9
    card.to_face_up!
    i += 1
    card
  end

  i = 0
  my_hand_cards = deck.cards.pop(2).map do |card|
    card.x = 228 + (card.image.width - 40) * i
    card.y = 420
    card.scale_x = 1.0
    card.scale_y = 1.0
    card.angle = -8 + 16*i
    card.to_face_up!
    i += 1
    card
  end

  i = 0
  enemy_hand_cards = deck.cards.pop(2).map do |card|
    card.x = 248 + (card.image.width - 60) * i
    card.y = -4
    card.scale_x = 0.8
    card.scale_y = 0.8
    card.angle = -6 + 12*i
    i += 1
    card
  end

  # 背景を描画
  Window.bgcolor = [40,118,60]

  Window.loop do
    cards.sort_by! { |c| -c.z }
    Sprite.check(my_hand_cards, common_cards)
    Sprite.update(cards)
    Sprite.draw(cards)
  end
end
