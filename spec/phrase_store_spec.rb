# encoding: UTF-8

require 'spec_helper'
require 'pathname'

include Rosette::Tms::FilestoreTms

describe PhraseStore do
  let(:repo_name) { 'my-awesome-repo' }
  let(:store_path) { File.join(Dir.tmpdir, Time.now.to_i.to_s) }
  let(:commit_id) { 'abc123' }

  let(:rosette_config) do
    Rosette.build_config do |config|
      config.add_repo(repo_name) do |repo_config|
        repo_config.use_tms('filestore') do |tms_config|
          tms_config.set_store_path(store_path)
        end
      end
    end
  end

  let(:repo_config) { rosette_config.get_repo(repo_name) }
  let(:configurator) { repo_config.tms.configurator }
  let(:phrase_store) { PhraseStore.new(configurator) }
  let(:contents) { JSON.parse(File.read(phrase_store.path)) }
  let(:phrase1) { Rosette::Core::Phrase.new('foo', 'bar') }
  let(:phrase2) { Rosette::Core::Phrase.new('baz', 'boo') }

  describe '#add_phrase' do
    it 'adds the phrase and writes it to disk' do
      phrase_store.add_phrase(phrase1, commit_id)
      expect(contents).to include(commit_id)
      expect(contents[commit_id].size).to eq(1)
      expect(contents[commit_id].first['key']).to eq(phrase1.key)
    end
  end

  describe '#add_phrases' do
    it 'adds multiple phrases at once' do
      phrase_store.add_phrases([phrase1, phrase2], commit_id)
      expect(contents).to include(commit_id)
      expect(contents[commit_id].size).to eq(2)
      expect(contents[commit_id].first['key']).to eq(phrase1.key)
      expect(contents[commit_id].last['key']).to eq(phrase2.key)
    end
  end

  describe '#get_phrases' do
    before(:each) do
      phrase_store.add_phrases([phrase1, phrase2], commit_id)
    end

    it 'retrieves phrases by commit id' do
      phrases = phrase_store.get_phrases(commit_id)
      expect(phrases.size).to eq(2)
      expect(phrases.map(&:key).sort).to eq(['baz', 'foo'])
    end
  end

  describe '#phrase_count' do
    context 'with no phrases added' do
      it 'returns zero' do
        expect(phrase_store.phrase_count(commit_id)).to eq(0)
      end
    end

    context 'with a phrase added' do
      before(:each) do
        phrase_store.add_phrase(phrase1, commit_id)
      end

      it 'returns one' do
        expect(phrase_store.phrase_count(commit_id)).to eq(1)
      end
    end
  end

  describe '#serialize' do
    it 'serializes the store as json' do
      phrase_store.add_phrase(phrase1, commit_id)
      result = JSON.parse(phrase_store.serialize)
      expect(result).to include(commit_id)
      expect(result[commit_id].size).to eq(1)
      expect(result[commit_id].first['key']).to eq(phrase1.key)
    end
  end

  describe '#delete' do
    it 'removes the store file from disk' do
      phrase_store.add_phrase(phrase1, commit_id)
      path = Pathname(phrase_store.path)
      expect(path).to exist
      phrase_store.delete
      expect(path).to_not exist
    end
  end
end
