require 'spec_helper'

describe Ohey::DragonflyBSD.new do
  subject { described_class }

  before do
    allow(subject).to receive(:uname_s).and_return("DragonflyBSD\n")
    allow(subject).to receive(:uname_r).and_return("7.1\n")
  end

  describe '#name' do
    it 'correctly identifies the platform' do
      expect(subject.name).to eq('dragonflybsd')
    end
  end

  describe '#family' do
    it 'correctly identifies the platform family' do
      expect(subject.family).to eq('dragonflybsd')
    end
  end

  describe '#build' do
    it 'correctly identifies the platform build' do
      expect(subject.build).to eq(nil)
    end
  end

  describe '#version' do
    it 'correctly identifies the platform version' do
      expect(subject.version).to eq('7.1')
    end
  end
end
