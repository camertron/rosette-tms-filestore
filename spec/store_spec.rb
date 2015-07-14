# encoding: UTF-8

require 'spec_helper'

describe Store do
  let(:store) { Store.new }

  # yes, this is a protected method, but it's important enough to test
  describe '#filesystem_sanitize' do
    it 'does not allow special characters in filenames' do
      expect(store.send(:filesystem_sanitize, 'foo/bar')).to eq('foo_bar')
    end
  end
end
