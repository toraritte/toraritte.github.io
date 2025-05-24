FreeSWITCH modules typically define three key functions:

  Load Function (SWITCH_MODULE_LOAD_FUNCTION):
  
  Initializes the module and registers its features (e.g., applications, APIs).
  Example: mod_erlang_event_load.
  Runtime Function (SWITCH_MODULE_RUNTIME_FUNCTION):
  
  Contains the main loop or background tasks for the module.
  Example: mod_erlang_event_runtime.
  Shutdown Function (SWITCH_MODULE_SHUTDOWN_FUNCTION):
  
  Cleans up resources when the module is unloaded.
  Example: mod_erlang_event_shutdown.
