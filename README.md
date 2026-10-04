# WIP - refactoring for MapPins

### DONE:
- very basic features, it draws icons on map (only skyshards and lorebooks for testing)
- checkboxes (PC version)
    - they are automatically scrollable now even if they were not like this b4 and original MapPins contains fragment to convert list into scrollable list. New in U51 or external addon does this?
- data separated into different files, going to keep it like this for future simplicity, and it can be good for loading (presumably)

### NOTES:
- sync checkboxes on different panels
    - currently if you uncheck checkbox on PvP panel, it stays checked on PvE because they are different controls after all
- need to rethink data structure to minimize amount of tables created, it looks like the main bottleneck in profiler
