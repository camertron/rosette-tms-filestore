[![Build Status](https://travis-ci.org/rosette-proj/rosette-tms-filestore.svg)](https://travis-ci.org/rosette-proj/rosette-tms-filestore) [![Code Climate](https://codeclimate.com/github/rosette-proj/rosette-tms-filestore/badges/gpa.svg)](https://codeclimate.com/github/rosette-proj/rosette-tms-filestore) [![Test Coverage](https://codeclimate.com/github/rosette-proj/rosette-tms-filestore/badges/coverage.svg)](https://codeclimate.com/github/rosette-proj/rosette-tms-filestore/coverage)

rosette-tms-filestore
===========================

A Rosette TMS (Translation Management System) that stores translations to disk (as opposed to a 3rd-party service). Think of this project like you might [ActiveSupport::Cache::FileStore](http://api.rubyonrails.org/classes/ActiveSupport/Cache/FileStore.html). Instead of integrating with a 3rd-party TMS like [Transifex](https://transifex.com) or [Smartling](https://smartling.com) to handle translation management, this project allows you to manage translations yourself and persists them locally to disk. As such, this TMS should usually be regarded as something only used during testing and development, as there isn't any nice interface exposed to translators.

## Installation

`gem install rosette-tms-filestore`

Then, somewhere in your project:

```ruby
require 'rosette/tms/filestore-tms'
```

### Introduction

This library is generally meant to be used with the Rosette internationalization platform. It provides a TMS that is capable of storing phrases and translations locally on disk. TMSs are configured per repo, so adding the filestore TMS might cause your Rosette config to look like this:

```ruby
require 'rosette/core'
require 'rosette/tms/filestore-tms'

rosette_config = Rosette.build_config do |config|
  config.add_repo('my-awesome-repo') do |repo_config|
    repo_config.use_tms('filestore') do |tms_config|
      tms_config.set_store_path('/path/to/store/location')
    end
  end
end
```

### Additional Features

In addition to implementing the [`Rosette::Tms::Repository` interface](http://www.rubydoc.info/github/rosette-proj/rosette-core/master/Rosette/Tms/Repository), the filestore TMS has a method capable of storing translations. This should make it straightforward to add new translations, something that's usually done by 3rd-party translators.

```ruby
locale = Rosette::Core::Locale.parse('es')
phrase = Rosette::Core::Phrase.new('Hello, world', 'hello_world_str')
rosette_config.tms.store_translation('Hola mundo', locale, phrase)
```

## Requirements

This project must be run under jRuby. It uses [expert](https://github.com/camertron/expert) to manage java dependencies via Maven. Run `bundle exec expert install` in the project root to download and install java dependencies.

## Running Tests

`bundle exec rake` or `bundle exec rspec` should do the trick.

## Authors

* Cameron C. Dutro: http://github.com/camertron
