require 'minitest/autorun'
require 'hobble/collection'

class TestCollection < Minitest::Test

  describe 'Hobble::Collection' do
    before do
      @collection = Hobble::Collection.new('foo')
    end

    describe '#new' do
      it 'should set the collection name' do
        assert_equal 'foo', @collection.name
      end

      it 'should set the debt to zero by default' do
        assert_equal 0, @collection.debt
      end

      it 'should set the debt another value if provided' do
        assert_equal 1, Hobble::Collection.new('foo', 1).debt
      end

      it 'should initialize empty items' do
        assert_equal [], @collection.items
      end

      it 'should not be ready?' do
        refute @collection.ready?
      end
    end

    describe 'with items' do
      before do
        @collection.add([1,2])
      end

      it 'should be ready?' do
        assert @collection.ready?
      end

      describe 'when sorting' do
        it 'should sort by debt' do
          @a, @b, @c = (1..3).map { @collection.dup }

          @a.stub(:debt, 3) { @b.stub(:debt, 1) { @c.stub(:debt, 2) {
            assert_equal [@b,@c,@a], [@a,@b,@c].sort
          } } }
        end

        it 'should swap equally with equally indebted collections' do
          @a, @b = Hobble::Collection.new('foo'), Hobble::Collection.new('bar')

          assert_equal [@b, @a], [@a, @b].sort
          assert_equal [@a, @b], [@a, @b].sort.sort
        end
      end

      describe '#add' do
        it 'should append more items' do
          @collection.add([3])
          assert_equal [1,2,3], @collection.items
        end
      end

      describe '#clear' do
        it 'should remove all items' do
          @collection.clear!
          assert_equal [], @collection.items
        end
      end

      describe '#clock' do
        it 'should call the supplied block' do
          given_name, given_items = nil, nil

          @collection.clock do |name, items|
            given_name, given_items = name, items
          end

          assert_equal 'foo', given_name
          assert_equal [1,2], given_items
        end

        it 'should cause debt to accrue' do
          previous = @collection.debt
          @collection.clock { |n,i| sleep(1e-3) }
          assert @collection.debt > previous
        end
      end
    end
  end

end
