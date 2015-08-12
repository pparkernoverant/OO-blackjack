

module Blackjack

  class Game

    def initialize
      @completed = false
      @deck = Deck.new
      @user = Human.new('User')
      @computer = Computer.new('Dealer')
      @players = [@user, @computer]
      @results = ""
    end


    def play
      if @completed
        puts @results
      else

        @players.each do |player|
          stayed = false
          busted = false

          puts "\n---------- #{player.name}'s turn ----------"
          player.cards << @deck.draw

          until stayed || busted
            player.cards << @deck.draw
            possible_scores = get_possible_scores(player.cards)

            if possible_scores.empty?
              busted = true
            else
              current_cards = "#{player.name}'s current cards: "
              player.cards.each {|card| current_cards << card.to_s + ", "}
              puts current_cards.chop!.chop!

              current_score = "#{player.name}'s current score: "
              possible_scores.each {|score| current_score << score.to_s + " or "}
              puts current_score.chop!.chop!.chop!.chop!

              choice = player.getChoice
              stayed = true if choice == 'stay'
            end
          end

          if busted
            puts "#{player.name} drew #{player.cards[-1]} and busted!" 
            @results << "#{@players.select {|x| x != player}[0].name} wins!"
            puts @results
            @completed = true
            break
          end
        end

      end

      if !@completed
        user_high_score = get_possible_scores(@user.cards).max
        computer_high_score = get_possible_scores(@computer.cards).max

        puts "\nFinal Scores:"
        puts "#{@user.name}'s score: #{user_high_score}"
        puts "#{@computer.name}'s score: #{computer_high_score}"

        if user_high_score > computer_high_score
          puts "Winner: #{@user.name}!"
        elsif computer_high_score > user_high_score
          puts "Winner #{@computer.name}"
        else
          puts "Tie goes to the house. #{@computer.name} wins!"
        end
     end
    end
  end

  class Deck
    @@suits = ['Spades', 'Hearts', 'Clubs', 'Diamonds']
    @@faces = ['Jack', 'Queen', 'King', 'Ace']
    (2..10).each {|x| @@faces << x.to_s}

    def initialize
      @cards = Array.new
      @@suits.each do |suit|
        @@faces.each do |face|
          @cards << Card.new(suit, face)
        end
      end
      @cards.shuffle!
    end

    def draw
      @cards.pop
    end
  end

  class Card
    attr_reader :suit, :face, :value
    
    def initialize(suit, face)
      @suit = suit
      @face = face

      if (2..10).include? face.to_i
        @value = face.to_i
      elsif ['Jack', 'Queen', 'King'].include? face
        @value = 10
      else
        @value = [1, 11]
      end
    end

    def to_s
      "#{face} of #{suit}"
    end
  end

  class Player
    attr_reader :name
    attr_accessor :cards

    def initialize(name)
      @name = name
      @cards = []
    end
  end

  class Human < Player
    def getChoice
      print "Hit or stay?: "
      choice = gets.chomp.downcase
      until ['hit', 'stay'].include? choice
        puts "Invalid input."
        print "Hit or stay?: "
        choice = gets.chomp.downcase
      end
      return choice
    end
  end

  class Computer < Player
    def getChoice
      if get_possible_scores(cards).select {|card| card > 16}.empty?
        choice = 'hit'
      else
        choice = 'stay'
      end

      return choice
    end
  end

  def get_possible_scores(cards)
    scores = [0]

    cards.each do |card|
      if card.face != 'Ace'
        scores.map! {|score| score + card.value} 
      else
        new_scores = Array.new
        scores.each do |score|
          new_scores << score + 1
          new_scores << score + 11
        end
        scores = new_scores
      end
    end

    return scores.uniq.select {|score| score < 22}
  end

end


include Blackjack

play_again = true
while play_again
  blackjack_game = Game.new
  blackjack_game.play
  
  puts "Play again? (Y/N)"
  play_again_input = gets.chomp
  play_again = false unless ['YES', 'Y'].include? play_again_input.upcase
end
