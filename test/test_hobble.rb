require 'minitest/autorun'
require 'hobble'

class TestHobble < Minitest::Test

  describe 'Hobble' do
    describe '#schedule' do
      it 'should return a new scheduler' do
        assert Hobble::Scheduler === Hobble.schedule({})
      end

      it 'should accept groups' do
        assert Hobble.schedule({})
      end

      it 'should accept a block' do
        assert Hobble.schedule() { {:a => [1,2]} }
      end

      it 'should not accept both groups and a block' do
        assert_raises(ArgumentError) do
          Hobble.schedule({}) { {:a => [1,2]} }
        end
      end
    end
  end

end
