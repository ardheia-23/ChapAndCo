# Name :		Chap&Co
# Author :		Ardheia
# Date :		14.06.2024
# Version:		1.1


require 'sketchup.rb'
require 'extensions.rb'

ChapAndCoExtension = SketchupExtension.new "Chap&Co", "ChapAndCo/ChapAndCo_menus.rb"

ChapAndCoExtension.name= "Chap&Co"
ChapAndCoExtension.creator = "Ardheia"
ChapAndCoExtension.copyright = "GPL"
ChapAndCoExtension.version = "1.1"
                        
Sketchup.register_extension ChapAndCoExtension, true
