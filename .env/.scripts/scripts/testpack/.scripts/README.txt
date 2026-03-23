========================================
  GOALEAF TESTPACK
========================================

Prerequisites
-------------
- Docker Desktop installed and running
- Windows 10/11


Getting Started
---------------
1. Extract this archive to any directory.
2. Double-click start.bat to launch the system.
   Alternatively, open a terminal (cmd) in the
   extracted directory and run: start.bat


Scripts
-------

start.bat
  Loads all Docker images and starts the Goaleaf system.
  You will be asked to choose a database mode:
    y - Single database (all services share one database)
    n - Multi database  (each service has its own database)

  Once started, the following services will be available:
    Webclient:    http://localhost:4200
    API Gateway:  http://localhost:8072
    Keycloak:     http://localhost:7080

  IMPORTANT: Do NOT close the start.bat window while using
  Goaleaf! The window must remain open to capture container
  logs. Closing it will stop all log recording. When you are
  done, use stop.bat in a separate terminal to shut down.

stop.bat
  Stops all running Goaleaf containers.
  Safe to run at any time.

clear.bat
  Removes only Goaleaf-related Docker resources (containers,
  images, networks) created by the compose files. Does not
  affect other Docker resources on your system.

  You will be asked the following questions:
    - Remove Docker volumes? (y/n)
        Choose 'y' to also delete database data.
        Choose 'n' to keep data for next run.
    - Run Docker system prune? (y/n)
        Removes dangling images and build cache.
        NOTE: System prune affects your entire Docker
        environment, not just Goaleaf resources.
    - Remove log files? (y/n)
        Only asked if a .logs/ directory exists.
        Choose 'y' to delete all saved log files.
        Choose 'n' to keep them for later inspection.

  IMPORTANT: After running clear.bat, you should also clear
  the browser's local storage for the webclient page:
    1. Open http://localhost:4200 in your browser
    2. Press F12 to open Developer Tools
    3. Go to the "Application" tab
    4. In the left sidebar, expand "Local storage"
    5. Right-click the localhost entry and select "Clear"
       (or select all entries and delete them)


Logs
----
Each time you run start.bat, container logs are automatically
captured to individual files in the .logs/ directory:

  .logs/<timestamp>/<container_name>.log

Each run creates a new timestamped subdirectory (e.g.,
.logs/2026-03-12_221530/), so logs from previous runs are
preserved. Running clear.bat will ask whether to remove
the log history.


Configuration
-------------
The compose/.env files contain connection settings and
credentials. These are pre-configured and should not
need changes for standard testing.


Troubleshooting
---------------
- Make sure Docker Desktop is running before using any script.
- If start.bat fails to load images, verify the .images/
  directory contains .tar files.
- If services fail to start, run stop.bat, then start.bat again.
- For a clean slate, run clear.bat followed by start.bat.
