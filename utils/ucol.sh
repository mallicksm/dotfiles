# ================================
# Universal 256-color palette
# for LS_COLORS / EXA_COLORS
# ================================

# --- Base 8-bit color codes ---
__c_reset="0"             # reset / default
__c_bold="01"             # bold modifier

# --- Primary ANSI hues ---
__c_black="38;5;0"
__c_gray="38;5;240"
__c_white="38;5;15"
__c_red="38;5;160"
__c_lightred="38;5;203"
__c_orange="38;5;208"
__c_yellow="38;5;226"
__c_green="38;5;40"
__c_lightgreen="38;5;82"
__c_blue="38;5;33"
__c_lightblue="38;5;39"
__c_purple="38;5;129"
__c_magenta="38;5;201"
__c_brown="38;5;94"
# --- Extended nice-looking hues (extras) ---
__c_pink="38;5;205"         # bright pink
__c_cyan="38;5;51"          # vivid cyan
__c_teal="38;5;44"          # sea teal
__c_aqua="38;5;87"          # light aqua
__c_sky="38;5;111"          # sky blue
__c_indigo="38;5;69"        # dark indigo
__c_olive="38;5;100"        # olive green
__c_lime="38;5;118"         # lime green
__c_gold="38;5;220"         # gold yellow
__c_tan="38;5;179"          # sand/tan
__c_maroon="38;5;124"       # dark red
__c_violet="38;5;177"       # soft violet
__c_salmon="38;5;209"       # salmon orange
__c_peach="38;5;215"        # peach
__c_coral="38;5;203"        # coral red
__c_slate="38;5;67"         # slate blue-gray
__c_ice="38;5;123"          # icy cyan-blue
__c_mint="38;5;121"         # mint green
__c_grape="38;5;135"        # deep purple
__c_rose="38;5;197"         # rose red
__c_lavender="38;5;183"     # lavender purple
__c_copper="38;5;172"       # copper brown
__c_silver="38;5;250"       # light silver gray
__c_coal="38;5;236"         # dark gray

# --- Core semantic roles ---
__c_dir="${__c_bold};${__c_blue}"    # directories
__c_link="${__c_lightblue}"          # symlinks
__c_exec="${__c_green}"              # executables
__c_socket="${__c_magenta}"          # sockets
__c_pipe="${__c_yellow}"             # pipes
__c_block="${__c_yellow}"            # block devices
__c_char="${__c_yellow}"             # char devices
__c_exec="${__c_green}"              # executables

# ================================
# LS_COLORS (direct color usage)
# ================================

LS_COLORS="no=${__c_reset}:fi=${__c_reset}"
LS_COLORS+=":di=${__c_dir}:ln=${__c_link}:mh=00:pi=${__c_pipe}:so=${__c_socket}"
LS_COLORS+=":bd=${__c_block}:cd=${__c_char}:or=${__c_red}:mi=${__c_red}:ex=${__c_exec}"
LS_COLORS+=":su=${__c_exec}:sg=${__c_exec}:ca=${__c_exec}"
LS_COLORS+=":tw=${__c_dir}:ow=${__c_dir}:st=${__c_dir}"
# archives
LS_COLORS+=":*.tar=${__c_red}:*.tgz=${__c_red}:*.zip=${__c_red}:*.gz=${__c_red}:*.bz2=${__c_red}"

# media
LS_COLORS+=":*.jpg=${__c_magenta}:*.png=${__c_magenta}:*.gif=${__c_magenta}:*.mp4=${__c_magenta}:*.mkv=${__c_magenta}"

# documents
LS_COLORS+=":*.pdf=${__c_red}:*.doc=${__c_lightblue}:*.docx=${__c_lightblue}:*.txt=${__c_lightblue}:*.md=${__c_lightblue}"

# scripts
LS_COLORS+=":*.sh=${__c_orange}:*.tdf=${__c_orange}:*.tcl=${__c_orange}:*.py=${__c_orange}"

# HDL (direct color)
LS_COLORS+=":*.sv=${__c_blue}:*.svh=${__c_blue}:*.v=${__c_blue}:*.vh=${__c_blue}"

# logs
LS_COLORS+=":*.log=${__c_silver}:*.list=${__c_purple}:*.f=${__c_lightred}"

# build system
LS_COLORS+=":*Makefile=${__c_orange}:*makefile=${__c_orange}:*GNUmakefile=${__c_orange}:*CMakeLists.txt=${__c_orange}:*.mk=${__c_orange}"

# my colors
LS_COLORS+=":*.c=${__c_silver}"
LS_COLORS+=":*.h=${__c_silver}"

export LS_COLORS

# ================================
# EXA_COLORS (same color base)
# ================================

EXA_COLORS="fi=${__c_reset}:di=${__c_dir}:ln=${__c_link}:pi=${__c_pipe}:so=${__c_socket}"
EXA_COLORS+=":bd=${__c_block}:cd=${__c_char}:or=${__c_red}:mi=${__c_red}:ex=${__c_exec}"
EXA_COLORS+=":ur=${__c_green}:uw=${__c_yellow}:ux=${__c_red}:ue=${__c_red}"
EXA_COLORS+=":gr=${__c_green}:gw=${__c_yellow}:gx=${__c_red}:tr=${__c_green}:tw=${__c_yellow}:tx=${__c_red}"
EXA_COLORS+=":Makefile=${__c_orange}:makefile=${__c_orange}:GNUmakefile=${__c_orange}:CMakeLists.txt=${__c_orange}:*.mk=${__c_orange}"

export EXA_COLORS
