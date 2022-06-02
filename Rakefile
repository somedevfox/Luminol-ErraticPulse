desc "Compile resources"
task :compile do
  require 'gtk3'
  require 'rubygems'

  app_root_path = File.expand_path(__dir__)
  resource_xml = File.join(app_root_path,  'lib', 'luminol', 'gresources.xml')
  resource_bin = File.join(app_root_path,  'lib', 'luminol', 'gresources.bin')

  `ridk enable` if Gem.win_platform?

  system(
    "glib-compile-resources",
    "--target", resource_bin,
    "--sourcedir", File.dirname(resource_xml),
    resource_xml
  )
end