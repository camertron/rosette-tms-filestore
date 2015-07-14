# encoding: UTF-8

require 'spec_helper'
require 'pathname'

include Rosette::Tms::FilestoreTms

describe TranslationStore do
  let(:repo_name) { 'my-awesome-repo' }
  let(:store_path) { File.join(Dir.tmpdir, Time.now.to_i.to_s) }
  let(:locale_code) { 'de-DE' }
  let(:locale) { repo_config.locales.first }

  let(:rosette_config) do
    Rosette.build_config do |config|
      config.add_repo(repo_name) do |repo_config|
        repo_config.add_locale(locale_code)

        repo_config.use_tms('filestore') do |tms_config|
          tms_config.set_store_path(store_path)
        end
      end
    end
  end

  let(:repo_config) { rosette_config.get_repo(repo_name) }
  let(:configurator) { repo_config.tms.configurator }
  let(:trans_store) { TranslationStore.new(configurator, locale) }
  let(:contents) { JSON.parse(File.read(trans_store.path)) }

  describe '#set' do
    it 'adds or updates a translation, writes to disk' do
      trans_store.set('foo', 'bar')
      expect(contents).to eq({ 'foo' => 'bar' })
    end
  end

  describe '#get' do
    it 'retrieves the translation from the given key' do
      trans_store.set('foo', 'bar')
      expect(trans_store.get('foo')).to eq('bar')
    end
  end

  describe '#serialize' do
    it 'serializes the store contents into a json hash' do
      trans_store.set('foo', 'bar')
      expect(trans_store.serialize).to eq(
        '{"foo":"bar"}'
      )
    end
  end

  describe '#delete' do
    it 'removes the store file from disk' do
      path = Pathname(trans_store.path)
      trans_store.set('foo', 'bar')
      expect(path).to exist
      trans_store.delete
      expect(path).to_not exist
    end
  end

  describe '#translation_count' do
    it 'returns the number of translations in the store' do
      trans_store.set('foo', 'bar')
      trans_store.set('baz', 'boo')
      expect(trans_store.translation_count).to eq(2)
    end
  end
end
