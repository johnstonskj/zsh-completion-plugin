# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Name: completion
# Description: Zsh plugin to setup Zsh completion.
# Repository: https://github.com/johnstonskj/zsh-completion-plugin
#
# Long description TBD.
#
# Public variables:
#
# * `COMPLETION`; plugin-defined global associative array with the following keys:
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
#   * `_PLUGIN_DIR`; the file in _PLUGIN_DIR the plugin is sourced from.
# * `COMPLETION_EXAMPLE`; if set it does something magical.
#

############################################################################
# Standard Setup Behavior
############################################################################

0="$(@zplugin_normalize_zero "${0}")"

@zplugin_declare_global completion "${0}"
    # To add custom directories to PATH:
    # path DIR
    # To add custom directories to FPATH:
    # fpath DIR
    # To save any global variables:
    # save VAR_NAME

############################################################################
# Plugin Lifecycle
############################################################################

#
# This function does the initialization of variables in the global variable
# `COMPLETION`. It also adds to `path` and `fpath` as necessary.
#
completion_plugin_init() {
    builtin emulate -L zsh
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

    # Export any additional environment variables here.
    #  @zplugin_save_global completion <VAR_NAME>

    # Define any aliases here, or in their own section below.

    # This should be the LAST step.
    @zplugin_register completion
}
@zplugin_remember_fn completion_plugin_init

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
completion_plugin_unload() {
    builtin emulate -L zsh

    # This should be the FIRST step.
    @zplugin_unregister completion

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

    _comp_path="${ZSH_COMPDUMP}"

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
    unset _comp_path

    zmodload zsh/complist
    zmodload zsh/curses
    autoload -Uz colors && colors

    # This should be the LAST step.
    unfunction completion_plugin_unload
}

############################################################################
# Plugin Public Things
############################################################################

@completion_add_dir() {
    @zplugin_add_to_fpath "${1}" "${2}"
}

@completion_remove_dir() {
    @zplugin_remove_from_fpath "${1}" "${2}"
}

############################################################################
# Plugin Initialization
############################################################################

completion_plugin_init

true
