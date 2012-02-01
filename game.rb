require 'rubygems'
require 'rubygame'

SCREEN_WIDTH  = 1024
SCREEN_HEIGHT = 768

class Game
    def initialize
        @screen = Rubygame::Screen.new [SCREEN_WIDTH, SCREEN_HEIGHT], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
        @screen.title = 'chastEyes'

        @queue = Rubygame::EventQueue.new
        @clock = Rubygame::Clock.new
        @clock.target_framerate = 60

        @things = []
        @things.push Player.new Point.new(20, @screen.height/2)
        @things.push Generator.new Bomb, 10
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

            @things.each {|thing| thing.handle_event event}
        end
    end

    def update delta_time
        @things.each {|thing| thing.update delta_time}
    end

    def draw screen
        screen.fill [0,0,0]
        @things.each {|thing| thing.draw @screen}
        screen.flip
    end
end


class Angle
    attr_accessor :radians

    DEGREES_PER_RADIAN = 180 / Math::PI
    RADIANS_PER_DEGREE = Math::PI / 180

    def initialize radians
        @radians = radians
    end

    def radians
        @radians
    end

    def degrees
        @radians * DEGREES_PER_RADIAN
    end

    def degrees= deg
        @radians = deg * RADIANS_PER_DEGREE
    end

    def opposite
        Angle.new @radians + Math::PI
    end

    def point
        Point.new Math.cos(@radians), Math.sin(@radians)
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

    def *(factor)
        Point.new @x * factor, @y * factor
    end

    def angle
        Angle.new Math.atan2(point.x, point.y)
    end
end


class Vector
    def initialize point
        @magnitude = Math.sqrt(point.x^2 + point.y^2)
        @angle = point.angle
    end

    def opposite
        Vector.new @angle.opposite.point * @magnitude
    end
end


def sign number
    return 1 if number >= 0
    return -1 if number < 0
end


class Thing
    def update delta_time
    end

    def draw screen
    end

    def handle_event event
    end
end


class Sprite < Thing
    attr_accessor :point, :width, :height, :surface

    def initialize point, surface
        @point = point
        @vx = 0.0
        @vy = 0.0
        @surface = surface
        @width = surface.width
        @height = surface.height
    end

    def update delta_time
        @point = @point + Point.new(@vx * delta_time, @vy * delta_time)
    end

    def draw screen
        @surface.blit screen, [@point.x, @point.y]
    end

    def handle_event event
    end
end


class Generator < Thing
    def initialize sprite, quota
        @sprite = sprite
        @quota = quota
        @sprites = []
    end

    def update delta_time
        @sprites.each {|sprite| @sprites.delete(sprite) if sprite.point.x < -sprite.width}
        meet_quota
        @sprites.each {|sprite| sprite.update delta_time}
    end

    def meet_quota
        (@quota - @sprites.size).times do
            point = Point.new SCREEN_WIDTH + 1, Random.rand(SCREEN_HEIGHT)
            @sprites.push @sprite.new point, -Random.rand(200.0..600.0), 0
        end
    end

    def draw screen
        @sprites.each {|sprite| sprite.draw screen}
    end
end


class Bomb < Sprite
    def initialize point, vx, vy
        super point, Rubygame::Surface.load('bomb.png')
        @vx = vx
        @vy = vy
    end
end


class Player < Sprite
    def initialize point
        super point, Rubygame::Surface.load('you.png')
        @drag   = 700.0 # pixels/second/second
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
            @vx = apply_drag(@vx, delta_time)
            @vy = apply_drag(@vy, delta_time)
        end

        super delta_time
    end

    def apply_drag velocity, delta_time
        new_velocity = velocity + (@drag * sign(velocity) * -1) * delta_time
        if sign(velocity) == sign(new_velocity)
            return new_velocity
        else
            return 0
        end
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
