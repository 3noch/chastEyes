require 'rubygems'
require 'rubygame'

class Game
    def initialize
        @screen = Rubygame::Screen.new [1024, 768], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
        @screen.title = 'chastEyes'

        @queue = Rubygame::EventQueue.new
        @clock = Rubygame::Clock.new
        @clock.target_framerate = 60

        @sprites = []
        @sprites.push Player.new Point.new(20, @screen.height/2)
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


class Point
    attr_accessor :x, :y

    def initialize x, y
        @x = x
        @y = y
    end

    def +(point)
        Point.new @x + point.x, @y + point.y
    end

    def -(point)
        Point.new @x - point.x, @y - point.y
    end

    def radians
        Math.atan2(point.x, point.y)
    end

    def degrees
        radians * 180 / Math::PI
    end
end


class BaseVector
    attr_accessor :point

    def magnitude
    end

    def magnitude=(mag)
    end
end

class PointVector < BaseVector
    def initialize point
        @point
    end

    def magnitude
        Math.sqrt( (p2.x - p1.x)^2 + (p2.y - p1.y)^2 )
    end
end


class DeltaVector < BaseVector
    def magnitude
        Math.sqrt( p2.x^2 + p2.y^2 )
    end
end


def sign number
    return 1 if number >= 0
    return -1 if number < 0
end


class Sprite
    attr_accessor :point, :width, :height, :surface

    def initialize point, surface
        @point = point
        @surface = surface
        @width = surface.width
        @height = surface.height
    end

    def update delta_time
    end

    def draw screen
        @surface.blit screen, [@point.x, @point.y]
    end

    def handle_event event
    end
end

class Player < Sprite
    def initialize point
        super point, Rubygame::Surface.load('you.png')
        @vx = 0.0
        @vy = 0.0
        @drag   = 500.0 # pixels/second/second
        @accel  = 1000.0 # pixels/second/second
        @moving = {:left => false, :right => false, :up => false, :down => false}
    end

    def update delta_time
        if moving?
            @vx = @vx - @accel * delta_time if @moving[:left]
            @vx = @vx + @accel * delta_time if @moving[:right]
            @vy = @vy - @accel * delta_time if @moving[:up]
            @vy = @vy + @accel * delta_time if @moving[:down]
        elsif
            @vx = @vx + (@drag * sign(@vx) * -1) * delta_time
            @vy = @vy + (@drag * sign(@vy) * -1) * delta_time
        end

        @point = @point + Point.new(@vx * delta_time, @vy * delta_time)
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
