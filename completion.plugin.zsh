# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name completion
# @brief Zsh plugin to setup Zsh completion.
# @repository https://github.com/johnstonskj/zsh-completion-plugin
#
# @description
#
# Long description TBD.
#
# ### State Variables
#
# * **PLUGIN**: Plugin-defined global associative array with the following keys:
#   * **_PATH**: The path to the plugin's sourced file.
#   * **_NAME**: The name of the plugin.
#   * **_CONTEXT**: The plugin's state context path.
#

############################################################################
# @section Setup
# @description Standard path and variable setup.
#

typeset -A PLUGIN
PLUGIN[_PATH]="$(@zplugins_normalize_zero "$0")"
PLUGIN[_NAME]="${${PLUGIN[_PATH]:t}%%.*}"
PLUGIN[_CONTEXT]="$(@zplugins_plugin_context ${PLUGIN[_NAME]})"

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

#
# @description 
#
# This function does the initialization of variables in the global variable
# `COMPLETION`. It also adds to `path` and `fpath` as necessary.
#
# @noargs
#
completion_plugin_init() {
    builtin emulate -L zsh
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

    export skip_global_compinit=1

    setopt COMPLETE_IN_WORD     # Complete from both ends of a word.
    setopt ALWAYS_TO_END        # Move cursor to the end of a completed word.
    setopt PATH_DIRS            # Perform path search even on command names with slashes.
    setopt AUTO_MENU            # Show completion menu on a successive tab press.
    setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
    setopt AUTO_PARAM_SLASH     # If completed parameter is a directory, add a trailing slash.
    setopt EXTENDED_GLOB        # Needed for file modification glob modifiers with compinit.
    unsetopt MENU_COMPLETE      # Do not autoselect the first completion entry.
    unsetopt FLOW_CONTROL       # Disable start/stop characters in shell editor.

    # Load and initialize the completion system ignoring insecure directories with a
    # cache time of 20 hours, so it should almost always regenerate the first time a
    # shell is opened each day.
    autoload -Uz compinit

    local _comp_path="${ZSH_COMPDUMP}"

    # #q expands globs in conditional expressions
    if [[ $_comp_path(#qNmh-20) ]]; then
        # -C (skip function check) implies -i (skip security check).
        compinit -C -d "$_comp_path"
    else
        mkdir -p "$_comp_path:h"
        compinit -i -d "$_comp_path"
        # Keep $_comp_path younger than cache time even if it isn't regenerated.
        touch "$_comp_path"
    fi

    zmodload zsh/complist
    zmodload zsh/curses
    autoload -Uz colors && colors

    # This should be the LAST step.
    @zplugin_register completion ${PLUGIN[_PATH]}
}
@zplugins_remember_fn completion_plugin_init

#
# @description
#
# Called when the plugin is unloaded to clean up after itself.
#
# @noargs
#
completion_plugin_unload() {
    builtin emulate -L zsh

    # This should be the FIRST step.
    @zplugin_unregister completion

    # This should be the LAST step.
    unfunction completion_plugin_unload
}

############################################################################
# @section Public
# @description Public functions, aliases, and varibles.
#

#
# @description Add a new directory to `fpath`.
#
# @arg $1 string The name of a plugin which will remember this path.
# @arg $2 path The path to add.
#
@completion_add_dir() {
    @zplugin_add_to_fpath "${1}" "${2}"
}
@zplugins_remember_fn @completion_add_dir

#
# @description Remove a new directory from `fpath`.
#
# @arg $1 string The name of a plugin which remembered this path.
# @arg $2 path The path to remove.
#
@completion_remove_dir() {
    @zplugin_remove_from_fpath "${1}" "${2}"
}
@zplugins_remember_fn @completion_remove_dir

############################################################################
# @section Initialization
# @description Final plugin initialization.
#

completion_plugin_init

true
