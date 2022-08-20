require 'opengl'
require 'gtk3'
GL.load_lib

MAX_C = 65535.0

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
    color = area.style.lookup_color("theme_bg_color")[1]

    GL.ClearColor(color.red / MAX_C, color.green / MAX_C, color.blue / MAX_C, 1)
    GL.Clear(GL::COLOR_BUFFER_BIT)
    GL.Flush
    true
  end
end
