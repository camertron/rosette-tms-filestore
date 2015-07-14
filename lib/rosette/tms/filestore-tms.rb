# encoding: UTF-8

require 'rosette/tms'

module Rosette
  module Tms

    module FilestoreTms
      autoload :Configurator,     'rosette/tms/filestore-tms/configurator'
      autoload :PhraseStore,      'rosette/tms/filestore-tms/phrase_store'
      autoload :Repository,       'rosette/tms/filestore-tms/repository'
      autoload :Store,            'rosette/tms/filestore-tms/store'
      autoload :TranslationStore, 'rosette/tms/filestore-tms/translation_store'

      def self.configure(rosette_config, repo_config)
        configurator = Configurator.new(rosette_config, repo_config)
        yield configurator
        Repository.new(configurator)
      end

    end

  end
end
