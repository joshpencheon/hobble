# frozen_string_literal: true

require 'hobble/collection'
require 'rspec'

describe Hobble::Collection do
  let(:collection) { described_class.new('foo') }
  let(:with_options) { described_class.new('foo', 3, 2) }

  describe '#new' do
    it 'sets the collection name' do
      expect(collection.name).to eq('foo')
    end

    it 'sets the debt to zero by default' do
      expect(collection.debt).to eq(0)
    end

    it 'sets the debt to another value if provided' do
      expect(with_options.debt).to eq(3 * 2)
    end

    it 'sets the weight to 1 by default' do
      expect(collection.weight).to eq(1)
    end

    it 'sets the weight if provided' do
      expect(with_options.weight).to eq(2)
    end

    it 'initializes empty items' do
      expect(collection.items).to eq([])
    end

    it 'is not ready?' do
      expect(collection.ready?).to be_falsey
    end
  end

  context 'with items' do
    before { collection.add([1, 2]) }

    it 'is ready?' do
      expect(collection.ready?).to be_truthy
    end

    describe 'when sorting' do
      it 'sorts by debt' do
        a, b, c = (1..3).map { collection.dup }
        allow(a).to receive(:debt).and_return(3)
        allow(b).to receive(:debt).and_return(1)
        allow(c).to receive(:debt).and_return(2)
        expect([a, b, c].sort).to eq([b, c, a])
      end

      it 'swaps equally with equally indebted collections' do
        a = described_class.new('foo')
        b = described_class.new('bar')
        expect([a, b].sort).to eq([b, a])
        expect([a, b].sort.sort).to eq([a, b])
      end
    end

    describe '#add' do
      it 'appends more items' do
        collection.add([3])
        expect(collection.items).to eq([1, 2, 3])
      end
    end

    describe '#clear!' do
      it 'removes all items' do
        collection.clear!
        expect(collection.items).to eq([])
      end
    end

    describe '#clock' do
      it 'calls the supplied block' do
        given_name = nil
        given_items = nil
        collection.clock do |name, items|
          given_name = name
          given_items = items
        end
        expect(given_name).to eq('foo')
        expect(given_items).to eq([1, 2])
      end

      it 'causes debt to accrue' do
        previous = collection.debt
        collection.clock { |_n, _i| sleep(0.001) }
        expect(collection.debt).to be > previous
      end

      context 'when weighted' do
        before { collection.weight = 5 }

        it 'factors weight when accruing debt' do
          prior_debt = collection.debt
          allow(collection).to receive(:time).and_return(3)
          collection.clock { |_n, _i| }
          expect(collection.debt - prior_debt).to eq(3 * 5)
        end
      end
    end
  end
end
