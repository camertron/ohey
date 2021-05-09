require 'spec_helper'

describe Ohey::FreeBSD do
  subject { described_class.new }

  before do
    allow(subject).to receive(:uname_s).and_return("FreeBSD\n")
    allow(subject).to receive(:uname_r).and_return("7.1\n")
  end

  describe '#name' do
    it 'correctly identifies the platform' do
      expect(subject.name).to eq('freebsd')
    end
  end

  describe '#family' do
    it 'correctly identifies the platform family' do
      expect(subject.family).to eq('freebsd')
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
