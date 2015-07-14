# encoding: UTF-8

require 'rosette/core'
require 'rosette/tms'
require 'digest/sha1'

module Rosette
  module Tms
    module FilestoreTms

      class Repository < Rosette::Tms::Repository
        attr_reader :configurator, :phrase_store, :trans_stores

        def initialize(configurator)
          @configurator = configurator
          @phrase_store = PhraseStore.new(configurator)
          @trans_stores = repo_config.locales.each_with_object({}) do |locale, ret|
            ret[locale.code] = TranslationStore.new(configurator, locale)
          end
        end

        def lookup_translations(locale, phrases)
          Array(phrases).map do |phrase|
            store_for(locale.code).get(phrase.index_value)
          end
        end

        def lookup_translation(locale, phrase)
          lookup_translations(locale, [phrase]).first
        end

        def store_phrases(phrases, commit_id)
          phrases.each do |phrase|
            phrase_store.add_phrase(phrase, commit_id)
          end
        end

        def store_phrase(phrase, commit_id)
          store_phrases([phrase], commit_id)
        end

        def checksum_for(locale, commit_id)
          digest = Digest::SHA1.new
          store = store_for(locale)

          store.pairs.keys.sort.each do |meta_key|
            digest << meta_key
            digest << store.get(meta_key)
          end

          digest.hexdigest
        end

        def status(commit_id)
          phrase_count = phrase_store.phrase_count(commit_id)
          Rosette::Core::TranslationStatus.new(phrase_count).tap do |status|
            repo_config.locales.each do |locale|
              trans_count = store_for(locale).translation_count
              status.add_locale_count(locale.code, trans_count)
            end
          end
        end

        def finalize(commit_id)
          # no cleanup necessary
        end

        def store_translation(translation_text, locale, phrase)
          store_for(locale).set(phrase.index_value, translation_text)
        end

        protected

        def store_for(locale)
          trans_stores[locale.code]
        end

        def repo_config
          configurator.repo_config
        end

        def rosette_config
          configurator.rosette_config
        end
      end

    end
  end
end
