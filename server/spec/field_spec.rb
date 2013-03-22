require_relative 'spec_helper'
require_relative '../field'
require 'json'

RESULTS_DIR = 'tmp/spec_data/'
WIDTH = 400
HEIGHT = 300

describe 'field' do
  # TODO: rename and make it an approval test

  it 'simulates bounded colliding balls' do
    field = Field.new(w: 400, h: 300)
    200.times do
      field.add_circle(
        rad: 5,
        pos: [rand(WIDTH), rand(HEIGHT)],
        vel: [rand(200) - 100, rand(200) - 100]
      )
    end
    frames = []
    360.times do
      frames << field.state
      field.step
    end
    write_to_file(frames, 'bounded')
  end

  private

  def write_to_file(content, filename)
    FileUtils.mkdir_p(RESULTS_DIR)
    File.open("#{ RESULTS_DIR }#{ filename }.json", 'w') { |f| f.write(JSON.generate(content)) }
  end

  def rand(num)
    Random.rand(num)
  end
end
