require 'rails_helper'

RSpec.describe Sleep, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:clock_in_time) }
  end

  describe 'db indexes' do
    it { is_expected.to have_db_index(:user_id) }
    it { is_expected.to have_db_index(:clock_in_time) }
    it { is_expected.to have_db_index(:clock_out_time) }
    it { is_expected.to have_db_index([ :user_id, :clock_in_time, :duration_minutes ]) }
  end

  describe 'scopes' do
    let(:user) { User.create!(name: 'Test User') }

    context 'with active scope' do
      it 'returns active sleep records' do
        active_sleep = described_class.create!(user: user, clock_in_time: Time.current)
        completed_sleep = described_class.create!(user: user, clock_in_time: 1.hour.ago, clock_out_time: Time.current, duration_minutes: 60)

        expect(described_class.active).to include(active_sleep)
      end

      it 'does not return completed sleep records' do
        active_sleep = described_class.create!(user: user, clock_in_time: Time.current)
        completed_sleep = described_class.create!(user: user, clock_in_time: 1.hour.ago, clock_out_time: Time.current, duration_minutes: 60)

        expect(described_class.active).not_to include(completed_sleep)
      end
    end

    context 'with completed scope' do
      it 'returns completed sleep records' do
        active_sleep = described_class.create!(user: user, clock_in_time: Time.current)
        completed_sleep = described_class.create!(user: user, clock_in_time: 1.hour.ago, clock_out_time: Time.current, duration_minutes: 60)

        expect(described_class.completed).to include(completed_sleep)
      end

      it 'does not return active sleep records' do
        active_sleep = described_class.create!(user: user, clock_in_time: Time.current)
        completed_sleep = described_class.create!(user: user, clock_in_time: 1.hour.ago, clock_out_time: Time.current, duration_minutes: 60)

        expect(described_class.completed).not_to include(active_sleep)
      end
    end
  end
end
