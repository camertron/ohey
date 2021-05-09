require 'spec_helper'

describe Ohey::NetBSD do
  subject { described_class.new }

  before do
    allow(subject).to receive(:uname_s).and_return("NetBSD\n")
    allow(subject).to receive(:uname_r).and_return("4.5\n")
  end

  describe '#platform' do
    it 'correctly identifies the platform' do
      expect(subject.name).to eq('netbsd')
    end
  end

  describe '#family' do
    it 'correctly identifies the platform family' do
      expect(subject.family).to eq('netbsd')
    end
  end

  describe '#build' do
    it 'correctly identifies the platform build' do
      expect(subject.build).to eq(nil)
    end
  end

  describe '#version' do
    it 'correctly identifies the platform version' do
      expect(subject.version).to eq('4.5')
    end
  end
end
