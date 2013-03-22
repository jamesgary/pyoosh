require 'chipmunk'

class Field
  TIMESTEP = 1.0 / 60.0

  def initialize(w: nil, h: nil, gravity: nil)
    @space = CP::Space.new
    @space.damping = 0.99
    @space.gravity = CP::Vec2.new(0, gravity) if gravity # FIXME affects static bodies
    if w && h
      @static_body = CP::Body.new_static
      @space.add_body(@static_body)
      [
        [[0, 0], [w, 0]],
        [[0, 0], [0, h]],
        [[w, h], [w, 0]],
        [[w, h], [0, h]],
      ].each do |a, b|
        shape = CP::Shape::Segment.new(@static_body, CP::Vec2.new(a[0], a[1]), CP::Vec2.new(b[0], b[1]), 1)
        shape.e = 0.9 # bounce!
        @space.add_static_shape(shape)
      end
    end
    @bodies = []
  end

  def add_circle(params)
    @bodies << Shapes::Circle.new(@space, params).body
  end

  def step
    @space.step(TIMESTEP)
  end

  def state
    {
      bodies: @bodies.map do |b|
        {
          x: b.p.x,
          y: b.p.y,
          a: b.a,
          rad: 5.0,
        }
      end
    }
  end

  module Shapes
    class Base
    end

    class Circle < Base
      attr_reader :body

      def initialize(space, mass: 1.0, rad: 1.0, pos: [0, 0], vel: nil)
        @rad    = rad
        @mass   = mass
        @pos    = CP::Vec2.new(pos[0], pos[1])
        @body   = CP::Body.new(@mass, inertia)
        @shape  = CP::Shape::Circle.new(@body, @rad, CP::Vec2::ZERO)
        @shape.u = 1 # friction, but it's not very noticable on circles
        @shape.e = 0.95 # 1.0 => perfect bounce
        @body.p = @pos
        @body.v = CP::Vec2.new(vel[0], vel[1]) if vel
        space.add_body(@body)
        space.add_shape(@shape)
      end

      private

      def inertia
        CP.moment_for_circle(@mass, 0, @rad, CP::Vec2::ZERO)
      end
    end

    class Rect < Base
    end

    class Shuriken < Base
    end
  end

  private

  def default_body
    @default_body ||= CP::Body.new(1.0, 1.0)
  end
end
