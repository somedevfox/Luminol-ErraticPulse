require 'opengl'
GL.load_lib

class Tilemap
  def initialize(area)
    @area = area

    area.signal_connect "render" do |area, context|
      render area, context
    end
  end

  def prepare

  end

  def render(area, context)
    GL.ClearColor(0.85, 0.85, 0.85, 1)
    GL.Clear(GL::COLOR_BUFFER_BIT)
    GL.Flush
    true
  end
end
