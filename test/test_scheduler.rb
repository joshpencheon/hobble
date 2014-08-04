require 'minitest/autorun'
require 'hobble/scheduler'

class TestScheduler < Minitest::Test

  describe 'Hobble::Scheduler' do
    before do
      @groups    = { :a => [4,2,3], :b => [1,3,6] }
      @scheduler = Hobble::Scheduler.new(@groups)
    end

    describe '#new' do
      it 'should accept groups' do
        assert Hobble::Scheduler.new({})
      end

      it 'should accept a block' do
        assert Hobble::Scheduler.new() { {:a => [1,2]} }
      end

      it 'should not accept both groups and a block' do
        assert_raises(ArgumentError) do
          Hobble::Scheduler.new({}) { {:a => [1,2]} }
        end
      end

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

    describe '#weight!' do
      before do
        @scheduler.weight!(:a => 0.001, :b => 0.005)
      end

      it 'should set collection weights' do
        a = @scheduler.collections.detect { |col| :a == col.name }
        assert_equal 0.001, a.weight
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
        @scheduler.run do |name, items|
          collection   = @scheduler.collections.find { |c| c.name == name }
          minimum_debt = @scheduler.collections.map(&:debt).min
          assert_equal minimum_debt, collection.debt

          # Accrue some debt:
          sleep(items.shift.to_f / 1e4)
        end
      end

      it 'should run a maximum number of times if given' do
        expected_times = 3
        actual_times   = 0

        @scheduler.run(expected_times) do |name, items|
          actual_times += 1
          items.shift
        end
        assert_equal expected_times, actual_times
      end

      it 'should reschedule using a populator block' do
        calls_left = 3
        scheduler  = Hobble::Scheduler.new do
          { :a => ((calls_left -= 1)...(2 * calls_left)).to_a }
        end

        expected_order = [3, 1]
        actual_order   = []

        scheduler.run { |n, items| actual_order << items.pop }

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
