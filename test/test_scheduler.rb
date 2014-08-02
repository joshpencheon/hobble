require 'minitest/autorun'
require 'hobble/scheduler'

class TestScheduler < Minitest::Test

  describe 'Hobble::Scheduler' do
    before do
      @groups    = { a: [4,2,3], b: [1,3,6] }
      @scheduler = Hobble::Scheduler.new(@groups)
    end

    describe '#new' do
      it 'should schedule the given groups' do
        assert_equal 2, @scheduler.collections.length
        assert_collection(:a, [4,2,3])
        assert_collection(:b, [1,3,6])
      end
    end

    describe '#schedule' do
      it 'should append to existing collections' do
        @scheduler.schedule(:a => [4,5])
        assert_equal 2, @scheduler.collections.length
        assert_collection(:a, [4,2,3,4,5])
      end

      it 'should create new collections' do
        @scheduler.schedule(:c => [1,2])
        assert_equal 3, @scheduler.collections.length
        assert_collection(:c, [1,2])
      end
    end

    describe '#clear!' do
      it 'should clear all collections' do
        mock_collection = Minitest::Mock.new
        mock_collection.expect(:clear!, true)
        @scheduler.stub(:collections, [mock_collection]) do
          @scheduler.clear!
          mock_collection.verify
        end
      end
    end

    describe '#run' do
      it 'should call schedule items fairly' do
        expected_order = [[:a, 4], [:b, 1], [:b, 3], [:a, 2], [:b, 6], [:a, 3]]
        actual_order   = []

        @scheduler.run do |name, items|
          item = items.shift
          sleep(item.to_f / 1e4)
          actual_order << [name, item]
        end

        assert_equal expected_order, actual_order
      end
    end

    def assert_collection(name, items)
      assert(@scheduler.collections.detect { |collection|
        collection.name == name && collection.items == items
      })
    end
  end

end
