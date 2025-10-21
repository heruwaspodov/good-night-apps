require 'rails_helper'

RSpec.describe DailySleepSummary, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:date) }
  end

  describe 'db indexes' do
    it { is_expected.to have_db_index([ :user_id, :date ]).unique(true) }
    it { is_expected.to have_db_index([ :user_id, :total_sleep_duration_minutes, :date ]) }
  end

  describe 'scopes' do
    let(:user) { User.create!(name: 'Test User') }

    context 'with for_date scope' do
      it 'finds records for a specific date' do
        date = Date.current
        summary = described_class.create!(user: user, date: date, total_sleep_duration_minutes: 480, number_of_sleep_sessions: 2)
        described_class.create!(user: user, date: 1.day.ago, total_sleep_duration_minutes: 420, number_of_sleep_sessions: 1)

        expect(described_class.for_date(date)).to include(summary)
      end

      it 'returns correct count for specific date' do
        date = Date.current
        described_class.create!(user: user, date: date, total_sleep_duration_minutes: 480, number_of_sleep_sessions: 2)
        described_class.create!(user: user, date: 1.day.ago, total_sleep_duration_minutes: 420, number_of_sleep_sessions: 1)

        expect(described_class.for_date(date).count).to eq(1)
      end
    end

    context 'with for_user scope' do
      it 'finds records for a specific user' do
        user1 = User.create!(name: 'User 1')
        user2 = User.create!(name: 'User 2')

        summary1 = described_class.create!(user: user1, date: Date.current, total_sleep_duration_minutes: 480, number_of_sleep_sessions: 2)
        summary2 = described_class.create!(user: user2, date: Date.current, total_sleep_duration_minutes: 420, number_of_sleep_sessions: 1)

        expect(described_class.for_user(user1)).to include(summary1)
      end

      it 'does not include other user records in user scope' do
        user1 = User.create!(name: 'User 1')
        user2 = User.create!(name: 'User 2')

        summary1 = described_class.create!(user: user1, date: Date.current, total_sleep_duration_minutes: 480, number_of_sleep_sessions: 2)
        summary2 = described_class.create!(user: user2, date: Date.current, total_sleep_duration_minutes: 420, number_of_sleep_sessions: 1)

        expect(described_class.for_user(user1)).not_to include(summary2)
      end
    end
  end
end
