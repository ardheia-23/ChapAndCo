class Face_i
  attr_accessor :x2, :x3, :q
end

class Edge_i
  attr_accessor :x, :ed, :q, :type
end

require 'ChapAndCo/ChapAndCo_code';
require 'matrix'

#Sketchup::require 'ChapAndCo/ChapAndCo_code.rb';

###################################################################################################
### Toolbar #######################################################################################
###################################################################################################

ChapAndCo_toolbar = UI::Toolbar.new "ChapAndCo";

cmd = UI::Command.new("Nouvelle forme") { nouvelle_forme }
cmd.small_icon = "buttons/maillage_small.png"
cmd.large_icon = "buttons/maillage_large.png"
cmd.tooltip = "Creer un maillage de chapiteau"
cmd.set_validation_proc {true ? MF_ENABLED : MF_GRAYED}#if not $cur_m then MF_ENABLED; else MF_GRAYED; end}
ChapAndCo_toolbar.add_item cmd

ChapAndCo_toolbar.add_separator


####################################################################################

cmd = UI::Command.new("Mise en tension") { mise_en_tension }
cmd.small_icon = "buttons/run_small.png"
cmd.large_icon = "buttons/run_large.png"
cmd.tooltip = "Met la toile sous tension"
cmd.set_validation_proc {true ? MF_ENABLED : MF_GRAYED}
ChapAndCo_toolbar.add_item cmd

#ChapAndCo_toolbar.add_separator;

cmd = UI::Command.new("Peinture") { peindre }
cmd.small_icon = "buttons/peindre_small.png"
cmd.large_icon = "buttons/peindre_large.png"
cmd.tooltip = "Peindre le chapiteau"
cmd.set_validation_proc {true ? MF_ENABLED : MF_GRAYED}
ChapAndCo_toolbar.add_item cmd

cmd = UI::Command.new("Découpe des laizes") { laize }
cmd.small_icon = "buttons/laize_small.png"
cmd.large_icon = "buttons/laize_large.png"
cmd.tooltip = "Mise à plats des laizes"
cmd.set_validation_proc {true ? MF_ENABLED : MF_GRAYED}
ChapAndCo_toolbar.add_item cmd


####################################################################################
=begin
cmd = UI::Command.new("Select membrane") { ChapAndCo_menu_selectall }
cmd.small_icon = "buttons/selectall_small.png"
cmd.large_icon = "buttons/selectall_large.png"
cmd.tooltip = "Modify"
cmd.set_validation_proc {if not $cur_m then MF_ENABLED; else MF_GRAYED; end}
ChapAndCo_toolbar.add_item cmd


####################################################################################

cmd = UI::Command.new("Set tension") { ChapAndCo_menu_tension }
cmd.small_icon = "buttons/tension_small.png"
cmd.large_icon = "buttons/tension_large.png"
cmd.tooltip = "Modify edge cable"
cmd.set_validation_proc {if $cur_m then MF_ENABLED; else MF_GRAYED; end}
ChapAndCo_toolbar.add_item cmd

####################################################################################

#cmd = UI::Command.new("Swap vertices") { ChapAndCo_menu_swap }
#cmd.small_icon = "buttons/swap_small.png"
#cmd.large_icon = "buttons/swap_large.png"
#cmd.tooltip = "Swap vertices"
#cmd.set_validation_proc {if $cur_m then MF_ENABLED; else MF_GRAYED; end}
#ChapAndCo_toolbar.add_item cmd

####################################################################################

cmd = UI::Command.new("Options") { ChapAndCo_menu_options }
cmd.small_icon = "buttons/options_small.png"
cmd.large_icon = "buttons/options_large.png"
cmd.tooltip = "Modify membrane"
cmd.set_validation_proc {if $cur_m then MF_ENABLED; else MF_GRAYED; end}
ChapAndCo_toolbar.add_item cmd

ChapAndCo_toolbar.add_separator

####################################################################################

####################################################################################

cmd = UI::Command.new("About") { UI.messagebox "ChapAndCo v 1.0 (Dec 2024)\n\n\nDevelopped by:\n\n\ Association ARDHEIA (www.ardheia.fr)\n\; }
cmd.small_icon = "buttons/about_small.png"
cmd.large_icon = "buttons/about_large.png"
cmd.tooltip = "About"
ChapAndCo_toolbar.add_item cmd

=end

