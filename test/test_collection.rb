require 'minitest/autorun'
require 'hobble/collection'

class TestCollection < Minitest::Test

  describe 'Hobble::Collection' do
    before do
      @collection = Hobble::Collection.new('foo')
    end

    describe '#new' do
      before do
        @with_options = Hobble::Collection.new('foo', 3, 2)
      end

      it 'should set the collection name' do
        assert_equal 'foo', @collection.name
      end

      it 'should set the debt to zero by default' do
        assert_equal 0, @collection.debt
      end

      it 'should set the debt to another value if provided' do
        assert_equal 3 * 2, @with_options.debt
      end

      it 'should set the weight to 1 by default' do
        assert_equal 1, @collection.weight
      end

      it 'should set the weight if provided' do
        assert_equal 2, @with_options.weight
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
          @a = Hobble::Collection.new('foo')
          @b = Hobble::Collection.new('bar')

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

        describe 'when weighted' do
          before do
            @collection.weight = 5
          end

          it 'should factor weight when accruing debt' do
            prior_debt = @collection.debt

            @collection.stub(:time, 3) do
              @collection.clock { |n,i| }
            end

            assert_equal 3 * 5, @collection.debt - prior_debt
          end
        end
      end
    end
  end

end
