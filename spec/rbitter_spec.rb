# encoding: utf-8

require "rbitter"

describe Rbitter do
  it 'Rbitter is a module' do
    expect(Rbitter.class === Module).to be(true)
  end

  context 'when a user requests help message,' do
    it 'shows help message' do
      Rbitter.bootstrap(['help'])
    end
  end

  context 'when \'configure\' option is given,' do
    it 'installs default config.json' do
      Rbitter.bootstrap(["configure"])
      expect(File.file?('config.json')).to be(true)
      expect(File.delete('config.json')).to be(1)
    end
  end

  context 'when config.json is installed,' do
    before(:all) do
      Rbitter.bootstrap(['configure'])
    end

    it 'executes prebootstrap properly' do
      Rbitter.prebootstrap
    end

    it 'bootstraps nothing when empty ARGV is given'  do
      Rbitter.bootstrap([])
    end

    it 'displays buffered logs with \'logs\' argument' do
      Rbitter.bootstrap(["logs"])
    end

    after(:all) do
      expect(File.file?('config.json')).to be(true)
      expect(File.delete('config.json')).to be(1)
    end
  end
end
