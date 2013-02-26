WIDTH = 400
HEIGHT = 300

module.exports = class Renderer
  constructor: (canvas) ->
    canvas.width = WIDTH
    canvas.height = HEIGHT
    @ctx = canvas.getContext("2d")
    @ctx.strokeStyle = "#222"
    @ctx.lineWidth = 1

  draw: (data) ->
    @ctx.clearRect 0, 0, WIDTH, HEIGHT
    for p in data.particles
      pos = p.pos
      @ctx.fillStyle = if p.mass > 1.5 then "#00bb00" else "#22ff22"
      @ctx.beginPath()
      @ctx.arc(pos.x, pos.y, p.radius, 0, 2 * Math.PI, false)
      @ctx.fill()
      @ctx.stroke()
