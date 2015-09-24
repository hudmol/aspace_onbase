# aspace_onbase
An ArchivesSpace plugin that supports uploading external documents to be stored in OnBase.
Developed for Dartmouth College.

## Installing it

To install, just activate the plugin in your config/config.rb file by
including an entry such as:

     # If you have other plugins loaded, just add 'container_management' to
     # the list
     AppConfig[:plugins] = ['local', 'other_plugins', 'aspace_onbase']

And then clone the `aspace_onbase` repository into your
ArchivesSpace plugins directory.  For example:

     cd /path/to/your/archivesspace/plugins
     git clone https://github.com/hudmol/aspace_onbase.git aspace_onbase


## Database Migration

This plugin comes with some database schema changes
that need to be applied.  To run the migration:

  1. Run the database setup script to update all tables to the latest
     version:

          cd /path/to/archivesspace
          scripts/setup-database.sh


## Configuration

This plugin requires the following configuration:

  * AppConfig[:onbase_robi_url] = "http://url.of.your.robi.service/api/documents"
  * AppConfig[:onbase_robi_username] = "username"
  * AppConfig[:onbase_robi_password] = "password"