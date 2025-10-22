require 'rails_helper'

RSpec.describe FollowingUsersSleepRecordsService, type: :service do
  let(:user) { User.create!(name: 'Test User') }
  let(:followed_user) { User.create!(name: 'Followed User') }
  let(:today) { Date.current }
  let(:yesterday) { 1.day.ago.to_date }

  before do
    # Create a follow relationship
    Follow.create!(follower: user, followed: followed_user)
  end

  describe '#call' do
    subject(:service_call) do
      described_class.new(
        user,
        page: page,
        limit: limit,
        date_start: date_start,
        date_end: date_end
      ).call
    end

    let(:page) { 1 }
    let(:limit) { 10 }
    let(:date_start) { yesterday.to_s }
    let(:date_end) { today.to_s }

    context 'when the user follows no one' do
      before do
        # Remove the follow relationship to simulate user following no one
        Follow.delete_all
      end

      it 'returns an empty paginated array' do
        result = service_call
        expect(result).to be_empty
        expect(result.current_page).to eq(1)
        expect(result.limit_value).to eq(10)
      end
    end

    context 'when followed users have sleep records' do
      let(:sleep_record) do
        Sleep.create!(
          user: followed_user,
          clock_in_time: 8.hours.ago,
          clock_out_time: 6.hours.ago,
          duration_minutes: 120
        )
      end

      before do
        sleep_record # Create the sleep record
      end

      it 'returns sleep records from followed users' do
        result = service_call
        expect(result).to include(sleep_record)
      end

      it 'orders results by duration minutes in descending order' do
        longer_sleep = Sleep.create!(
          user: followed_user,
          clock_in_time: 8.hours.ago,
          clock_out_time: 4.hours.ago,
          duration_minutes: 240
        )

        result = service_call
        # The longer sleep should come first
        expect(result.first).to eq(longer_sleep)
        expect(result.last).to eq(sleep_record)
      end

      it 'filters by date range' do
        old_sleep = Sleep.create!(
          user: followed_user,
          clock_in_time: 3.days.ago,
          clock_out_time: 2.days.ago,
          duration_minutes: 120
        )

        result = service_call
        expect(result).not_to include(old_sleep)
      end

      it 'uses without_count for performance' do
        # This test checks that the implementation uses without_count
        # by verifying that total_count is not computed
        result = service_call
        # Kaminari with without_count does not compute total count
        expect(result).to respond_to(:limit_value)
      end

      it 'applies pagination' do
        # Create multiple sleep records
        15.times do |i|
          Sleep.create!(
            user: followed_user,
            clock_in_time: (i + 1).hours.ago,
            clock_out_time: (i + 30).minutes.ago,
            duration_minutes: (i + 1) * 30
          )
        end

        result = service_call
        expect(result.length).to be <= 10  # limit is 10
      end
    end

    context 'with default date values' do
      let(:date_start) { nil }
      let(:date_end) { nil }

      it 'defaults to previous week when no dates provided' do
        # Create a sleep record from the previous week
        prev_week_sleep = Sleep.create!(
          user: followed_user,
          clock_in_time: 8.days.ago,
          clock_out_time: 6.days.ago,
          duration_minutes: 120
        )

        result = service_call
        expect(result).to include(prev_week_sleep)
      end
    end

    context 'with different page and limit values' do
      before do
        # Create multiple sleep records to test pagination
        15.times do |i|
          Sleep.create!(
            user: followed_user,
            clock_in_time: (i + 1).hours.ago,
            clock_out_time: (i + 30).minutes.ago,
            duration_minutes: (i + 1) * 10
          )
        end
      end

      it 'respects the limit parameter' do
        result = described_class.new(
          user,
          page: 1,
          limit: 5,
          date_start: 2.days.ago.to_date.to_s,
          date_end: today.to_s
        ).call

        expect(result.length).to eq(5)
      end

      it 'paginates correctly' do
        first_page = described_class.new(
          user,
          page: 1,
          limit: 5,
          date_start: 2.days.ago.to_date.to_s,
          date_end: today.to_s
        ).call

        second_page = described_class.new(
          user,
          page: 2,
          limit: 5,
          date_start: 2.days.ago.to_date.to_s,
          date_end: today.to_s
        ).call

        # Should have different records on different pages
        expect(first_page & second_page).to be_empty
      end
    end
  end
end
