require 'gtk3'
require_relative 'luminol_window'

class Application < Gtk::Application
  def initialize
    super 'com.nowaffles.luminol', :flags_none

    signal_connect :activate do |app|
      window = LuminolWindow.new(app)
      window.present
    end
  end
end
