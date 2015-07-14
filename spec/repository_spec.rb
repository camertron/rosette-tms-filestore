# encoding: UTF-8

require 'spec_helper'

include Rosette::Core
include Rosette::Tms::FilestoreTms

describe Repository do
  let(:repo_name) { 'my-awesome-repo' }
  let(:locale_code) { 'de-DE' }
  let(:locale) { repo_config.locales.first }
  let(:store_path) { File.join(Dir.tmpdir, Time.now.to_i.to_s) }
  let(:commit_id) { 'abc123' }

  let(:rosette_config) do
    Rosette.build_config do |config|
      config.add_repo(repo_name) do |repo_config|
        repo_config.use_tms('filestore') do |tms_config|
          repo_config.add_locale(locale_code)
          tms_config.set_store_path(store_path)
        end
      end
    end
  end

  let(:repo_config) { rosette_config.get_repo(repo_name) }
  let(:configurator) { repo_config.tms.configurator }
  let(:phrase1) { Rosette::Core::Phrase.new('foo', 'bar') }
  let(:phrase2) { Rosette::Core::Phrase.new('baz', 'boo') }
  let(:repository) { Repository.new(configurator) }

  context 'with a few translations' do
    before(:each) do
      repository.store_translation('foosbar', locale, phrase1)
      repository.store_translation('foosbarbeitsch', locale, phrase2)
    end

    describe '#lookup_translation' do
      it 'retrieves the correct translation for the given phrase' do
        repository.lookup_translation(locale, phrase1).tap do |translation|
          expect(translation).to eq('foosbar')
        end
      end
    end

    describe '#lookup_translations' do
      it 'retrieves the correct translations for the given phrases' do
        repository.lookup_translations(locale, [phrase1, phrase2]).tap do |translations|
          expect(translations).to include('foosbar')
          expect(translations).to include('foosbarbeitsch')
        end
      end
    end

    describe '#checksum_for' do
      it 'calculates the same checksum every time' do
        checksum = repository.checksum_for(locale, commit_id)
        expect(checksum).to eq(repository.checksum_for(locale, commit_id))
      end
    end
  end

  describe '#store_phrase' do
    it 'stores a single phrase' do
      expect { repository.store_phrase(phrase1, commit_id) }.to(
        change { repository.phrase_store.phrase_count(commit_id) }.from(0).to(1)
      )
    end
  end

  describe '#store_phrases' do
    it 'stores multiple phrases' do
      expect { repository.store_phrases([phrase1, phrase2], commit_id) }.to(
        change { repository.phrase_store.phrase_count(commit_id) }.from(0).to(2)
      )
    end
  end

  describe '#status' do
    before(:each) do
      repository.store_phrases([phrase1, phrase2], commit_id)
    end

    it 'returns a partially translated status if not all phrases are translated' do
      repository.store_translation('foosbar', locale, phrase1)
      status = repository.status(commit_id)
      expect(status).to be_a(TranslationStatus)
      expect(status.percent_translated(locale.code)).to eq(0.5)
    end

    it 'returns a fully translated status if all phrases are translated' do
      repository.store_translation('foosbar', locale, phrase1)
      repository.store_translation('foosbarbeitsch', locale, phrase2)
      status = repository.status(commit_id)
      expect(status).to be_a(TranslationStatus)
      expect(status.percent_translated(locale.code)).to eq(1.0)
    end
  end

  describe '#store_translation' do
    it 'stores the translation' do
      expect { repository.store_translation('foosbar', locale, phrase1) }.to(
        change { repository.trans_stores[locale.code].translation_count }.from(0).to(1)
      )
    end
  end
end
