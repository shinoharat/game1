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

module Dragable
  def click?
    hover? && Input.mouse_push?(M_LBUTTON)
  end

  def drag?
    hover? && Input.mouse_down?(M_LBUTTON)
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
    if click?
      @click_x = center_x - Input.mouse_x
      @click_y = center_y - Input.mouse_y
    end

    if drag?
      self.center_x = Input.mouse_x - @click_x
      self.center_y = Input.mouse_y - @click_y
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
    @score = calc_score
    super(4 + n * 8, 4 + n * 8, calc_image)
  end

  def update
    super
  end

  def to_s
    "#{SUIT_TABLE[suit]}#{NUM_TABLE[number]}"
  end

  private

  def calc_score
    number.clamp(1, 10)
  end

  def calc_image
    Image[:"#{suit}_#{number}"]
  end
end

class Deck
  attr_reader :cards

  def initialize
    suits = Card::SUIT_TABLE.keys
    numbers = [*1..13]

    @cards = suits.flat_map { |s| numbers.map { |n| Card.new(s, n) } }
  end
end

class Common
end


Window.load_resources do

  deck = Deck.new
  c1, c2, c3 = deck.cards.sample(3)

  # 背景を描画
  Window.bgcolor = [40,118,60]

  Window.loop do
    c1.update
    c1.draw

    c2.update
    c2.draw

    c3.update
    c3.draw
  end
end
