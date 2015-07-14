# encoding: UTF-8

require 'thread'
require 'json'
require 'fileutils'

module Rosette
  module Tms
    module FilestoreTms

      class PhraseStore < Store
        attr_reader :commits, :path

        def initialize(configurator)
          @path = File.join(
            configurator.store_path,
            filesystem_sanitize(configurator.repo_config.name),
            'phrase-store.json'
          )

          @write_mutex = Mutex.new
          load_commits
        end

        def add_phrase(phrase, commit_id)
          commits[commit_id] << phrase
          flush
        end

        def add_phrases(phrases, commit_id)
          phrases.each do |phrase|
            add_phrase(phrase, commit_id)
          end
        end

        def get_phrases(commit_id)
          (commits[commit_id] || [])
        end

        def phrase_count(commit_id)
          get_phrases(commit_id).size
        end

        def flush
          @write_mutex.synchronize do
            FileUtils.mkdir_p(File.dirname(path))
            File.open(path, 'w+') do |f|
              f.write(serialize)
            end
          end
        end

        def serialize
          commits.each_with_object({}) do |(commit_id, phrases), ret|
            ret[commit_id] = phrases.map(&:to_h)
          end.to_json
        end

        def delete
          File.unlink(path)
        end

        protected

        def load_commits
          @commits = if File.exist?(path)
            json = JSON.parse(File.read(path))
            json.each_with_object({}) do |(commit_id, phrases), ret|
              ret[commit_id] = phrases.map do |phrase_hash|
                Rosette::Core::Phrase.from_h(
                  phrase_hash.each_with_object({}) do |(key, val), phrase_ret|
                    phrase_ret[key.to_sym] = val
                  end
                )
              end
            end
          else
            Hash.new { |h, k| h[k] = [] }
          end
        end
      end

    end
  end
end
