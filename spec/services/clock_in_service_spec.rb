require 'rails_helper'

RSpec.describe ClockInService, type: :service do
  let(:user) { User.create!(name: 'Test User') }

  describe '#call' do
    context 'when user does not have an active clock-in' do
      it 'creates a new sleep record with clock_in_time' do
        result, errors = described_class.call(user.id)

        expect(result).to be_present
        expect(errors).to be_nil
        expect(result.user_id).to eq(user.id)
        expect(result.clock_in_time).to be_present
        expect(result.clock_out_time).to be_nil
      end
    end

    context 'when user already has an active clock-in' do
      before do
        Sleep.create!(user: user, clock_in_time: Time.current)
      end

      it 'returns error' do
        result, errors = described_class.call(user.id)

        expect(result).to be_nil
        expect(errors).to include('User must clock out before clocking in again')
      end
    end
  end
end
