require 'opengl'
GL.load_lib

require 'gtk3'
require_relative 'autotiles'
require_relative '../system/system'

class Tilemap
  attr_reader :ani_index

  BLANK_AUTOTILE = GdkPixbuf::Pixbuf.new(
    width: 96, height: 128, has_alpha: true
  )

  def initialize(area)
    @ani_index = 0
    @area = area
  end

  def ani_index=(val)
    @ani_index = val
    @ani_index %= 3
  end

  def prepare
    @map = System.map
    return if @map.nil?
    @data = @map.data
    tileset = System.tilesets[@map.tileset_id]
    @tileset = System::Cache.load_image_surf(
      "Graphics", "Tilesets",
      tileset.tileset_name
    )
    @autotiles = []
    tileset.autotile_names.each do |autotile|
      if autotile == ""
        @autotiles << BLANK_AUTOTILE
        next
      end

      @autotiles << System::Cache.load_image_surf(
        "Graphics", "Autotiles", autotile
      )
    end

    @area.width_request = @map.width * 32
    @area.height_request = @map.height * 32
  end

  def draw(_, ctx)
    return if @data.nil? || @map.nil?
    @data.each do |val, x, y, _|
      if val >= 384
        draw_tile(ctx, val, x, y)
      else
        draw_autotile(ctx, val, x, y)
      end
    end
    ctx.destroy
  end

  def draw_tile(ctx, id, x, y)
    id -= 384
    t = @tileset.sub_rectangle_surface(
      (id % 8) * 32, (id / 8) * 32,
      32, 32
    )
    ctx.set_source t, x * 32, y * 32
    ctx.paint
    t.destroy
  end

  def draw_autotile(ctx, id, x, y)
    return if id < 48
    autotile = @autotiles[
      (id / 48) - 1
    ]
    corners = AUTOTILES[
      id % 48
    ]
    ani_size = autotile.width / 96
    2.times do |sA|
      2.times do |sB|
        ti = corners[sA + (sB * 2)]
        tx = ti % 6
        ty = (ti / 6)
        sX = sA * 16
        sY = sB * 16

        if ani_size.positive?
          tx += 6 * (@ani_index % ani_size)
        end

        t = autotile.sub_rectangle_surface(
          tx * 16, ty * 16,
          16, 16
        )
        ctx.set_source t, x * 32 + sX, y * 32 + sY
        ctx.paint
        t.destroy
      end
    end
  end
end
