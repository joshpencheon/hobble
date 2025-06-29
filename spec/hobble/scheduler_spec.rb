# frozen_string_literal: true

require 'hobble/scheduler'
require 'rspec'

def assert_collection(scheduler, name, items)
  expect(scheduler.collections.any? { |col| col.name == name && col.items == items }).to be_truthy
end

describe Hobble::Scheduler do
  let(:groups) { { a: [4, 2, 3], b: [1, 3, 6] } }
  let(:scheduler) { described_class.new(groups) }

  describe '#new' do
    it 'accepts groups' do
      expect(described_class.new({})).to be_truthy
    end

    it 'accepts a block' do
      expect(described_class.new { { a: [1, 2] } }).to be_truthy
    end

    it 'does not accept both groups and a block' do
      expect { described_class.new({}) { { a: [1, 2] } } }.to raise_error(ArgumentError)
    end

    it 'schedules the given groups' do
      expect(scheduler.collections.length).to eq(2)
      assert_collection(scheduler, :a, [4, 2, 3])
      assert_collection(scheduler, :b, [1, 3, 6])
    end
  end

  describe '#schedule' do
    it 'appends to existing collections' do
      scheduler.schedule(a: [4, 5])
      expect(scheduler.collections.length).to eq(2)
      assert_collection(scheduler, :a, [4, 2, 3, 4, 5])
    end

    it 'creates new collections' do
      scheduler.schedule(c: [1, 2])
      expect(scheduler.collections.length).to eq(3)
      assert_collection(scheduler, :c, [1, 2])
    end
  end

  describe '#weight!' do
    before { scheduler.weight!(a: 0.001, b: 0.005) }

    it 'sets collection weights' do
      a = scheduler.collections.detect { |col| :a == col.name }
      expect(a.weight).to eq(0.001)
    end
  end

  describe '#clear!' do
    it 'clears all collections' do
      mock_collection = double('Collection')
      expect(mock_collection).to receive(:clear!).and_return(true)
      allow(scheduler).to receive(:collections).and_return([mock_collection])
      scheduler.clear!
    end
  end

  describe '#run' do
    it 'calls schedule items fairly' do
      scheduler.run do |name, items|
        collection = scheduler.collections.find { |c| c.name == name }
        minimum_debt = scheduler.collections.map(&:debt).min
        expect(collection.debt).to eq(minimum_debt)
        sleep(items.shift.to_f / 1e4)
      end
    end

    it 'runs a maximum number of times if given' do
      expected_times = 3
      actual_times = 0
      scheduler.run(expected_times) do |_name, items|
        actual_times += 1
        items.shift
      end
      expect(actual_times).to eq(expected_times)
    end

    it 'reschedules using a populator block' do
      calls_left = 3
      scheduler2 = described_class.new do
        { a: ((calls_left -= 1)...(2 * calls_left)).to_a }
      end
      expected_order = [3, 1]
      actual_order = []
      scheduler2.run { |_n, items| actual_order << items.pop }
      expect(actual_order).to eq(expected_order)
    end
  end
end
