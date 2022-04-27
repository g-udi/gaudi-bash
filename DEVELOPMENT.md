# gaudi-bash Development

This page summarizes a couple of rules to keep in mind when developing features or making changes in gaudi-bash.

## Debugging and Logging

### General Logging

While developing feature or making changes in general, you can log error/warning/debug
using `_log_error` `_log_warning` and `_log_debug`. This will help you solve problems quicker
and also propagate important notes to other users of gaudi-bash.
You can see the logs by using `gaudi-bash doctor` command to reload and see the logs.
Alternatively, you can set `GAUDI_BASH_LOG_LEVEL` to `GAUDI_BASH_LOG_LEVEL_ERROR`, `GAUDI_BASH_LOG_LEVEL_WARNING` or `GAUDI_BASH_LOG_LEVEL_ALL`.

### Log Prefix/Context

You can define `GAUDI_BASH_LOG_PREFIX` in your files in order to a have a constant prefix before your logs.
Note that we prefer to uses "tags" based logging, i.e `plugins: git: DEBUG: Loading git plugin`.


## Load Order

### General Load Order

The main `gaudi_bash.sh` script loads the frameworks individual components in the following order:

* `lib/composure.bash`
* Files in `lib` with the exception of `appearance.bash` - this means that `composure.bash` is loaded again here (possible improvement?)
* Enabled `aliases`
* Enabled `plugins`
* Enabled `completions`
* `themes/colors.theme.bash`
* `themes/base.theme.bash`
* `lib/appearance.bash`, which loads the selected theme
* Custom `aliases`
* Custom `plugins`
* Custom `completions`
* Additional custom files from either `$GAUDI_BASH/custom` or `$GAUDI_BASH_CUSTOM`

This order is subject to change.

### Individual Component Load Order

For `aliases`, `plugins` and `completions`, the following rules are applied that influence the load order:

* There is a global `enabled` directory, which the enabled components are linked into. Enabled plugins are symlinked from `$GAUDI_BASH/plugins/available` to `$GAUDI_BASH/enabled` for example. All component types are linked into the same common `$GAUDI_BASH/enabled` directory.
* Within the common `enabled` directories, the files are loaded in alphabetical order, which is based on the item's load priority (see next item).
* When enabling a component, a _load priority_ is assigned to the file. The following default priorities are used:
    * Aliases: 150
    * Plugins: 250
    * Completions: 350
* When symlinking a component into the `enabled` directory, the load priority is used as a prefix for the linked name, separated with three dashes from the name of the component. The `node.plugin.bash` would be symlinked to `250---node.plugin.bash` for example.
* Each file can override the default load priority by specifying a new value. To do this, the file needs to include a comment in the following form. This example would cause the `node.plugin.bash` (if included in that file) to be linked to `225---node.plugin.bash`:

  ```bash
  # GAUDI_BASH_LOAD_PRIORITY: 225
  ```

Having the order based on a numeric priority in a common directory allows for more flexibility. While in general, aliases are loaded first (since their default priority is 150), it's possible to load some aliases after the plugins, or some plugins after completions by setting the items' load priority. This is more flexible than a fixed type-based order or a strict alphabetical order based on name.

These items are subject to change. When making changes to the internal functionality, this page needs to be updated as well.

## Plugin Disable Callbacks

Plugins can define a function that will be called when the plugin is being disabled.
The callback name should be `{PLUGIN_NAME}_on_disable`, you can see `gitstatus` for usage example.
