require_relative 'rgss_classes'
require_relative 'rpg_classes'
require 'gtk3'

module System
  class << self
    attr_accessor :working_directory, :map
    DATA_TYPES = {
      tilesets: "Tilesets",
      mapinfos: "MapInfos"
    }.freeze
    DATA_TYPES.each { |t, _| attr_accessor t }

    def load_data
      DATA_TYPES.each do |var, file|
        instance_variable_set("@#{var}", load_file(file))
      end
    end

    def load_file(filename)
      File.open(
        File.join(working_directory, "Data", filename) + '.rxdata', "rb"
      ) do |file|
        return Marshal.load(file)
      end
    end

    def load_map(id)
      map = "Map#{id.to_s.rjust(3, "0")}"
      load_file(map)
    end
  end

  module Cache
    @cache = {}
    @autotiles_cache = {}

    def self.load_image(*paths)
      path = File.join(System.working_directory, *paths) + ".png"
      if @cache.include?(path)
        return @cache[path]
      end

      buf = GdkPixbuf::Pixbuf.new(
        file: path
      )
      @cache[path] = buf
    end
  end
end
