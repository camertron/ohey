require 'spec_helper'

describe Ohey::Windows do
  subject { described_class.new }

  before do
    version = double('WIN32OLE', name: 'Version')
    os_type = double('WIN32OLE', name: 'OsType')
    os = double('WIN32OLE', properties_: [version, os_type])

    allow(os).to receive(:invoke).with(version.name).and_return('6.1.7601')
    allow(os).to receive(:invoke).with(os_type.name).and_return(18)

    os_wmi = WmiLite::Wmi::Instance.new(os)
    allow_any_instance_of(WmiLite::Wmi).to receive(:first_of).with('Win32_OperatingSystem').and_return(os_wmi)
  end

  describe '#name' do
    it 'correctly identifies the platform' do
      expect(subject.name).to eq('WINNT')
    end
  end

  describe '#family' do
    it 'correctly identifies the platform family' do
      expect(subject.family).to eq('windows')
    end
  end

  describe '#build' do
    it 'correctly identifies the platform build' do
      expect(subject.build).to eq(nil)
    end
  end

  describe '#version' do
    it 'correctly identifies the platform version' do
      expect(subject.version).to eq('6.1.7601')
    end
  end
end