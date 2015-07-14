# encoding: UTF-8

module Rosette
  module Tms
    module FilestoreTms

      class Configurator
        attr_reader :rosette_config, :repo_config, :store_path

        def initialize(rosette_config, repo_config)
          @rosette_config = rosette_config
          @repo_config = repo_config
          @store_path = ''
        end

        def set_store_path(path)
          @store_path = path
        end
      end

    end
  end
end
