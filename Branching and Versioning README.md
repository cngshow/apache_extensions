### Notes on project structure

The development branch of this project, should be the latest and greatest of the configs for all platforms - it mirrors what we are doing in dev
as work progresses on a release.

The R2 / R3 / R4 branches are intended to track the configuration - primarily for preprod and prod - for their configuration at deployment time.

The flow is that the pre and prod files are setup / prepared in dev - but then when ready for release, they are promoted to a new branch that cooresponds 
to the release.

These are branches, rather than tags, as we often find issues later, that need to be corrected after the official release is made.