
require 'rubygems'
require 'rubygame'

class Game
    def initialize
        @screen = Rubygame::Screen.new [1024, 768], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
        @screen.title = 'CatalEyes'

        @queue = Rubygame::EventQueue.new
        @clock = Rubygame::Clock.new
        @clock.target_framerate = 60

        @sprites = []
        @sprites.push Player.new 20, @screen.height/2
    end

    def run!
        loop do
            delta_time = @clock.tick / 1000.0
            handle_events
            update delta_time
            draw @screen
        end
    end

    def handle_events
        @queue.each do |event|
            case event
                when Rubygame::QuitEvent
                    Rubygame.quit
                    exit
                when Rubygame::KeyDownEvent
                    if event.key == Rubygame::K_ESCAPE
                        @queue.push Rubygame::QuitEvent.new
                    end
            end

            @sprites.each {|sprite| sprite.handle_event event}
        end
    end

    def update delta_time
        @sprites.each {|sprite| sprite.update delta_time}
    end

    def draw screen
        screen.fill [0,0,0]
        @sprites.each {|sprite| sprite.draw @screen}
        screen.flip
    end
end


def sign number
    return 1 if number >= 0
    return -1 if number < 0
end


class Sprite
    attr_accessor :x, :y, :width, :height, :surface

    def initialize x, y, surface
        @x = x
        @y = y
        @surface = surface
        @width = surface.width
        @height = surface.height
    end

    def update delta_time
    end

    def draw screen
        @surface.blit screen, [@x, @y]
    end

    def handle_event event
    end
end


class Player < Sprite
    def initialize x, y
        super x, y, Rubygame::Surface.load('you.png')
        @vx     = 0.0 # pixels/second
        @vy     = 0.0 # pixels/second
        @vvx    = 0.0 # pixels/second/second
        @vvy    = 0.0 # pixels/second/second
        @vdecay = 300.0 # pixels/second/second
        @accel  = 300.0 # pixels/second/second
        @moving = {:left => false, :right => false, :up => false, :down => false}
    end

    def update delta_time
        if moving?
            @vvx = @vvx - @accel * delta_time if @moving[:left]
            @vvx = @vvx + @accel * delta_time if @moving[:right]
            @vvy = @vvy - @accel * delta_time if @moving[:up]
            @vvy = @vvy + @accel * delta_time if @moving[:down]
        elsif
            @vvx = @vvx + (@vdecay * sign(@vvx) * -1) * delta_time
            @vvy = @vvy + (@vdecay * sign(@vvy) * -1) * delta_time
        end

        @vx = @vx + @vvx * delta_time
        @vy = @vy + @vvy * delta_time

        @x = @x + @vx * delta_time
        @y = @y + @vy * delta_time
    end

    def moving?
        @moving[:left] or @moving[:right] or @moving[:up] or @moving[:down]
    end

    def handle_event event
        case event
            when Rubygame::KeyDownEvent
                if event.key == Rubygame::K_RIGHT
                    @moving[:right] = true
                elsif event.key == Rubygame::K_LEFT
                    @moving[:left] = true
                elsif event.key == Rubygame::K_UP
                    @moving[:up] = true
                elsif event.key == Rubygame::K_DOWN
                    @moving[:down] = true
                end
            when Rubygame::KeyUpEvent
                if event.key == Rubygame::K_RIGHT
                    @moving[:right] = false
                elsif event.key == Rubygame::K_LEFT
                    @moving[:left] = false
                elsif event.key == Rubygame::K_UP
                    @moving[:up] = false
                elsif event.key == Rubygame::K_DOWN
                    @moving[:down] = false
                end
        end
    end
end

g = Game.new
g.run!
