# frozen_string_literal: true

require 'hobble'
require 'rspec'

describe Hobble do
  describe '#schedule' do
    it 'returns a new scheduler' do
      expect(Hobble.schedule({})).to be_a(Hobble::Scheduler)
    end

    it 'accepts groups' do
      expect(Hobble.schedule({})).to be_truthy
    end

    it 'accepts a block' do
      expect(Hobble.schedule { { a: [1, 2] } }).to be_truthy
    end

    it 'does not accept both groups and a block' do
      expect { Hobble.schedule({}) { { a: [1, 2] } } }.to raise_error(ArgumentError)
    end
  end
end
