# completion

Zsh plugin to setup Zsh completion.

## Overview

Long description TBD.

### State Variables

* **PLUGIN**: Plugin-defined global associative array with the following keys:
  * **_PATH**: The path to the plugin's sourced file.
  * **_NAME**: The name of the plugin.
  * **_CONTEXT**: The plugin's state context path.

## Index

* [completion_plugin_init](#completionplugininit)
* [completion_plugin_unload](#completionpluginunload)
* [@completion_add_dir](#completionadddir)
* [@completion_remove_dir](#completionremovedir)

## Lifecycle

Standard path and variable setup.

### completion_plugin_init

This function does the initialization of variables in the global variable
`COMPLETION`. It also adds to `path` and `fpath` as necessary.

_Function has no arguments._

### completion_plugin_unload

Called when the plugin is unloaded to clean up after itself.

_Function has no arguments._

## Public

Public functions, aliases, and varibles.

### @completion_add_dir

Add a new directory to `fpath`.

#### Arguments

* **$1** (string): The name of a plugin which will remember this path.
* **$2** (path): The path to add.

### @completion_remove_dir

Remove a new directory from `fpath`.

#### Arguments

* **$1** (string): The name of a plugin which remembered this path.
* **$2** (path): The path to remove.

