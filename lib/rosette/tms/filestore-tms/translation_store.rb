# encoding: UTF-8

require 'thread'
require 'json'

module Rosette
  module Tms
    module FilestoreTms

      class TranslationStore < Store
        attr_reader :path, :locale, :pairs

        def initialize(configurator, locale)
          @locale = locale

          @path = File.join(
            configurator.store_path,
            filesystem_sanitize(configurator.repo_config.name),
            filesystem_sanitize("translation-store-#{locale.code}.json")
          )

          @write_mutex = Mutex.new
          load_pairs
        end

        def set(key, value)
          pairs[key] = value
          flush
        end

        def get(key)
          pairs[key]
        end

        def flush
          @write_mutex.synchronize do
            File.open(path, 'w+') do |f|
              f.write(serialize)
            end
          end
        end

        def serialize
          pairs.to_json
        end

        def delete
          File.unlink(path)
        end

        def translation_count
          pairs.size
        end

        protected

        def load_pairs
          @pairs = if File.exist?(path)
            JSON.parse(File.read(path))
          else
            {}
          end
        end
      end

    end
  end
end
