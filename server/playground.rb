require 'percolator'

class Playground
  WIDTH = 400
  HEIGHT = 300
  SPEED_RANGE = -10.0..10.0
  def initialize
    @percolator = Percolator.new
    collision  = Percolator::Behaviors::Collision.new
    edge_bound = Percolator::Behaviors::EdgeBound.new(
      Percolator::Vector.new(0, 0), # min
      Percolator::Vector.new(WIDTH, HEIGHT) # max
    )
    50.times do
      Percolator::Particle.new(
        radius: 7,
        mass: 1.0,
        pos: Percolator::Vector.new(rand(WIDTH), rand(HEIGHT)),
        vel: Percolator::Vector.new(rand(SPEED_RANGE), rand(SPEED_RANGE))
      ).tap do |p|
        @percolator.add_particle(p)
        collision.add_particle(p)
      end
    end
    50.times do
      Percolator::Particle.new(
        radius: 9,
        mass: 2.0,
        pos: Percolator::Vector.new(rand(WIDTH), rand(HEIGHT)),
        vel: Percolator::Vector.new(rand(SPEED_RANGE), rand(SPEED_RANGE))
      ).tap do |p|
        @percolator.add_particle(p)
        collision.add_particle(p)
      end
    end
    @percolator.add_behavior(collision)
    @percolator.add_behavior(edge_bound)
  end

  def step
    @percolator.step
  end

  def to_h
    @percolator.to_h
  end
end
