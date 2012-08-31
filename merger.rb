# encoding: utf-8
# Diese kleine Programm verbindet Html-Seiten mit ausgelagerten Templates
# Warum?
# Wird eine Single Page Application (SPA) z.b. mit KnockoutJS erstellt, entstehen
# mit der Zeit viele Templates die alle in einer Html-Datei liegen. 
# Das wird unübersichtlich (und das Syntax-Highlight leidet auch darunter).
# Mit diesem Script können die Templates in eigene Dateien ausgelagert werden
# um später wieder zu einer einzelnen datei kompiliert zu werden.
#
# Die Templates werden folgendermaßen in die HTML-Datei eingebunden:
#   <script id="<template_datei_name_ohne_ext" type="text/template">
#     ...template..
#  </script>
#  
require 'optparse'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}

optparse = OptionParser.new do|opts|
	# Set a banner, displayed at the top
	# of the help screen.
	opts.banner = "Usage: merger.rb [options]"

	# Define the options, and what they do
	options[:input_name] = 'index_.html'
	opts.on( '-i', '--input FILE', 'Hier sollen die Templates rein. Datei dient als Vorlage und wird NICHT geändert.' ) do |name|
		options[:input_name] = name
	end

	options[:output_name] = 'index.html'
	opts.on( '-o', '--output FILE', 'In diese Datei wird die Mischung aus Html und Templates geschrieben.' ) do |name|
		options[:output_name] = name
	end

	options[:templates_dir] = 'templates/*.html'
	opts.on( '-t', '--templates PATH', 'Mit diesem Suchpfad werden die Templates gesucht.' ) do |path|
		options[:templates_dir] = path
	end

	options[:watch] = false
	opts.on( '-w', '--watch', 'Automatischer Merge, wenn sich Input-Datei oder ein Template geändert haben.' ) do
		options[:watch] = true
	end

	options[:watch_interval] = 1
	opts.on( '-i', '--interval SECONDS', 'In diesem Interval[s] wird überwacht.' ) do |seconds|
		options[:watch_interval] = seconds
	end

	# This displays the help screen, all programs are
	# assumed to have this option.
	opts.on( '-h', '--help', 'Zeigt diese Hilfe an.' ) do
		puts opts
		exit
	end
end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!


# Optionen
Index_name = options[:input_name]
Template_dir = options[:templates_dir]
Output_name = options[:output_name]
Watch = options[:watch]
Watch_Interval = options[:watch_interval]

#
# Html-Datei mit den Templates verbinden
#
def merge_templates
	# Hier sollen die Templates hin.
	index_content = ''
	# Der HTML-Code für alle Templates
	template_markup = ''

	# Zieldatei einlesen.
	File.open(Index_name, 'r') {|f| index_content = f.read() }

	# Templates finden
	template_names = Dir.glob(Template_dir)

	# Alle Templates verarbeiten
	template_names.each do |template_name|
		template_content = ''
		# Template laden.
		File.open(template_name, 'r') {|f| template_content = f.read() }

		# Template Id aus dem Namen erzeugen
		template_id = File.basename(template_name, ".*")
		
		# Markup erzeugen. 
		markup = "<script id=\"#{template_id}\" type=\"text/template\">\n#{template_content}\n</script>"

		# Markup einfügen
		template_markup += "\n#{markup}\n"
	end

	# Fertiges Markup in Html-Code einfügen.
	index_content.gsub!(/<templates\/>|<templates><\/templates>/, template_markup)

	# Neue Datei schreiben
	File.open(Output_name, 'w') {|f| f.write(index_content) }

	puts "#{Index_name} + #{template_names.length} Templates => #{Output_name}"
end

#
# Nach Änderungen in Dateien Ausschau halten
#
def watch_files(files, &block)
	while true do
		files = Dir.glob(files)
		new_hash = files.collect {|f| [ f, File.stat(f).mtime.to_i ] }
		hash ||= new_hash
		diff_hash = new_hash - hash
	 
		unless diff_hash.empty?
			hash = new_hash
	 
			diff_hash.each do |df|
				block.call(df[0])
			end
		end
	 
		sleep Watch_Interval
	end
end


# -----------------------------------------------
# MAIN
# -----------------------------------------------
if Watch
	puts "Watching #{Index_name} and #{Template_dir}..."

	watch_files [Index_name, Template_dir] do |changed_file|
		print "Detected change in #{changed_file}, merging: "
		merge_templates
	end

else
	merge_templates
end

