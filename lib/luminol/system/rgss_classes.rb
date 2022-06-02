class Table
  include Enumerable

  attr_reader :xsize, :ysize, :zsize

  def initialize(x_size = 1, y_size = 1, z_size = 1)
    @xsize, @ysize, @zsize = x_size, y_size, z_size

    @elements = Array.new(z_size) {
      Array.new(y_size) { Array.new(x_size) { 0 } }
    }

    @num_of_dimensions = 1
    @num_of_dimensions += 1 if y_size > 1
    @num_of_dimensions += 1 if z_size > 1

    @num_of_elements = @xsize * @ysize * @zsize
  end

  def size_check(x, y, z)
    x >= @xsize || y >= @ysize || z >= @zsize
  end

  def [](x, y = 0, z = 0)
    return nil if size_check(x, y, z)
    @elements[z][y][x]
  end

  def []=(x, y = 0, z = 0, val)
    raise "Out of bounds!" if size_check(x, y, z)
    @elements[z][y][x] = val
  end

  def resize(x, y = 1, z = 1)
    new_elements = Array.new(z) do |z_index|
      Array.new(y) do |y_index|
        Array.new(x) do |x_index|
          ele = self[x_index, y_index, z_index]
          ele ||= 0
          ele
        end
      end
    end
    @elements = new_elements
  end

  def each
    if block_given?
      @elements.each_with_index do |z, z_index|
        z.each_with_index do |y, y_index|
          y.each_with_index do |x, x_index|
            yield x, x_index, y_index, z_index
          end
        end
      end
    else
      to_enum(:each)
    end
  end

  def _dump(limit)
    [@num_of_dimensions, @xsize, @ysize, @zsize, @num_of_elements, *@elements.flatten].pack("VVVVVv*")
  end

  def self._load(obj)
    data = obj.unpack("VVVVVv*")
    num_of_dimensions, xsize, ysize, zsize, _, *elements = *data
    if num_of_dimensions > 1
      if xsize > 1
        elements = elements.each_slice(xsize).to_a
      else
        elements = elements.map{|element|[element]}
      end
    end
    if num_of_dimensions > 2
      if ysize > 1
        elements = elements.each_slice(ysize).to_a
      else
        elements = elements.map{|element|[element]}
      end
    end
    t = Table.new(xsize, ysize, zsize)
    t.instance_variable_set(:@elements, elements)
    t
  end
end


class Color
  attr_accessor :red, :green, :blue, :alpha

  def initialize(red, green, blue, alpha=255)
    @red, @green, @blue, @alpha = red, green, blue, alpha
  end

  def _dump(limit)
    [@red, @green, @blue, @alpha].pack("EEEE")
  end

  def self._load(obj)
    Color.new(*obj.unpack("EEEE"))
  end
end

class Tone
  attr_accessor :red, :green, :blue, :gray

  def initialize(red, green, blue, gray=0)
    @red, @green, @blue, @gray = red, green, blue, gray
  end

  def _dump(limit)
    [@red, @green, @blue, @gray].pack("EEEE")
  end

  def self._load(obj)
    Tone.new(*obj.unpack("EEEE"))
  end
end