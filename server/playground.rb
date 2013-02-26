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

    @attractors = {}
  end

  def step
    @percolator.step
  end

  def player_move(player, target)
    if attractor = @attractors[player.id]
      attractor.target.x = target[0]
      attractor.target.y = target[1]
    else
      @percolator.add_behavior(
        @attractors[player.id] = Percolator::Behaviors::Attraction.new(
          target: Percolator::Vector.new(target[0], target[1]),
          radius: 200.0,
          strength: 2.0,
        )
      )
    end
  end

  def player_exit(player)
    @percolator.remove_behavior(@attractors.delete(player.id))
  end

  def to_h
    @percolator.to_h
  end
end
