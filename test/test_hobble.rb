require 'minitest/autorun'
require 'hobble'

class TestHobble < Minitest::Test

  describe 'Hobble' do
    describe '#schedule' do
      it 'should return a new scheduler' do
        assert Hobble::Scheduler === Hobble.schedule({})
      end
    end
  end

end
