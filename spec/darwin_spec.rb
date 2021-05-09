require 'spec_helper'

describe Ohey::Darwin do
  subject { described_class.new }

  before do
    allow(subject).to receive(:sw_vers).and_return([
      'ProductName:	Mac OS X',
      'ProductVersion:	10.15.6',
      'BuildVersion:	19G46c'
    ])
  end

  describe '#name' do
    it 'correctly identifies the platform' do
      expect(subject.name).to eq('mac_os_x')
    end
  end

  describe '#family' do
    it 'correctly identifies the platform family' do
      expect(subject.family).to eq('mac_os_x')
    end
  end

  describe '#build' do
    it 'correctly identifies the platform build' do
      expect(subject.build).to eq('19G46c')
    end
  end

  describe '#platform_version' do
    it 'correctly identifies the platform version' do
      expect(subject.version).to eq('10.15.6')
    end
  end
end
