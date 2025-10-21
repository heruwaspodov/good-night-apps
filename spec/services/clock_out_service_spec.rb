require 'rails_helper'

RSpec.describe ClockOutService, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { User.create!(name: 'Test User') }
  let(:sleep) { Sleep.create!(user: user, clock_in_time: 1.hour.ago) }

  describe '#call' do
    context 'when sleep record exists' do
      it 'sets clock_out_time to current time' do
        travel_to Time.current do
          result, errors = described_class.call(sleep.id)

          expect(result).to be_present
          expect(errors).to be_nil
          expect(result.clock_out_time).to be_within(1.second).of(Time.current)
        end
      end

      it 'calculates duration_minutes correctly' do
        travel_to Time.current do
          sleep = Sleep.create!(user: user, clock_in_time: 2.hours.ago)
          result, _ = described_class.call(sleep.id)

          expect(result.duration_minutes).to eq(120) # 2 hours = 120 minutes
        end
      end

      it 'saves the updated record' do
        old_clock_out_time = sleep.clock_out_time
        old_duration = sleep.duration_minutes

        result, _ = described_class.call(sleep.id)

        expect(result.id).to eq(sleep.id)
        expect(result.clock_out_time).not_to eq(old_clock_out_time)
        expect(result.duration_minutes).not_to eq(old_duration)
      end
    end

    context 'when sleep record does not exist' do
      it 'returns error' do
        result, errors = described_class.call(999)

        expect(result).to be_nil
        expect(errors).to include('Sleep record not found')
      end
    end
  end
end
