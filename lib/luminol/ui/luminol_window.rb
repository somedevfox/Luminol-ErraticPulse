require 'gtk3'
require_relative '../system/system'

class LuminolWindow < Gtk::ApplicationWindow
  type_register

  CHILDREN = %w[open_button new_button close_button settings_button].freeze
  OPENED_CHILDREN = %w[cut_button copy_button paste_button delete_button layers_menu scale_slider database_button
                       sound_test_button test_button tile_picker map_infos map pencil_button rectangle_button
                       circle_button fill_button map_label coords].freeze

  ID_COL = 0
  NAME_COL = 1

  def self.init
    set_template resource: '/com/nowaffles/luminol/ui/luminol.glade'

    (CHILDREN + OPENED_CHILDREN).each { |c| bind_template_child c }
  end

  def initialize(app)
    super application: app

    create_mapinfos_renderer

    open_button.signal_connect 'clicked' do |button, app|
      open_project
    end

    map_infos.signal_connect "cursor-changed" do |tree|
      change_map(tree)
    end
  end

  def enable_widgets
    OPENED_CHILDREN.each do |c|
      instance_variable_get("@#{c}").sensitive = true
    end
  end

  def disable_widgets
    OPENED_CHILDREN.each do |c|
      instance_variable_get("@#{c}").sensitive = false
    end
  end

  def create_mapinfos_tree
    model = Gtk::TreeStore.new(
      Integer, String
    )

    System.mapinfos = System.mapinfos.sort_by { |_, m| m.order }

    iters = []
    System.mapinfos.each do |id, mapinfo|
      if iters.last && (iters.last[ID_COL] != mapinfo.parent_id)
        while iters.last && iters.last[ID_COL] != mapinfo.parent_id
          iters.pop
        end
      end
      iter = model.append iters.last
      iter[ID_COL] = id
      iter[NAME_COL] = mapinfo.name
      iters << iter
    end

    map_infos.model = model
  end

  def create_mapinfos_renderer
    name_renderer = Gtk::CellRendererText.new
    map_infos.insert_column(
      -1, "Map", name_renderer, text: NAME_COL
    )
    #id_renderer = Gtk::CellRendererText.new
    #map_infos.insert_column(
    #  -1, "ID", id_renderer, text: ID_COL
    #)
  end

  def change_map(tree)
    tree.selection.each do |_, _, iter|
      System.map = System.load_map(iter[ID_COL])
    end

  end

  def open_project
    dialog = Gtk::FileChooserDialog.new(
      title: "Open an existing project",
      parent: self
    )
    dialog.add_buttons(
      [Gtk::Stock::CANCEL, :cancel],
      [Gtk::Stock::OPEN, :accept]
    )
    dialog.filter = Gtk::FileFilter.new
    dialog.filter.add_pattern("*.luminol")
    dialog.filter.add_pattern("*.rxproj")
    response = dialog.run

    if response == :accept
      System.working_directory = File.dirname(dialog.filename)
      System.load_data
    end

    dialog.destroy

    create_mapinfos_tree
    enable_widgets
  end
end
