require 'spec_helper'

describe Ohey::Aix do
  subject { described_class.new }

  before do
    allow(subject).to receive(:uname_rvp).and_return(
      "2 7 powerpc".split
    )
  end

  describe '#name' do
    it 'correctly identifies the platform' do
      expect(subject.name).to eq('aix')
    end
  end

  describe '#family' do
    it 'correctly identifies the platform family' do
      expect(subject.family).to eq('aix')
    end
  end

  describe '#build' do
    it 'correctly identifies the platform build' do
      expect(subject.build).to eq(nil)
    end
  end

  describe '#version' do
    it 'correctly identifies the platform version' do
      expect(subject.version).to eq('7.2')
    end
  end
end
