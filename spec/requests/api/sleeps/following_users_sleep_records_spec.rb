require 'rails_helper'

RSpec.describe 'Api::Sleeps#following_users_sleep_records', type: :request do
  let(:user) { User.create!(name: 'Test User') }
  let(:followed_user) { User.create!(name: 'Followed User') }
  let(:another_followed_user) { User.create!(name: 'Another Followed User') }
  let(:today) { Date.current }
  let(:yesterday) { 1.day.ago.to_date }

  before do
    # Create follow relationships
    Follow.create!(follower: user, followed: followed_user)
    Follow.create!(follower: user, followed: another_followed_user)

    # Create some sleep records
    Sleep.create!(
      user: followed_user,
      clock_in_time: 10.hours.ago,
      clock_out_time: 8.hours.ago,
      duration_minutes: 120
    )

    Sleep.create!(
      user: another_followed_user,
      clock_in_time: 9.hours.ago,
      clock_out_time: 6.hours.ago,
      duration_minutes: 180
    )
  end

  describe 'GET /api/sleeps/following_users_sleep_records' do
    let(:request_headers) { { 'X-User-Id' => user.id } }
    let(:valid_params) do
      {
        page: 1,
        limit: 10,
        date_start: yesterday.to_s,
        date_end: today.to_s
      }
    end

    context 'with valid parameters' do
      it 'returns success response with sleep records' do
        get '/api/sleeps/following_users_sleep_records',
            headers: request_headers,
            params: valid_params

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/json')

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('data')

        # Should include sleep records from followed users
        sleep_data = json_response['data']
        expect(sleep_data).to be_an(Array)
        expect(sleep_data.length).to be >= 1
      end

      it 'returns records ordered by duration in descending order' do
        get '/api/sleeps/following_users_sleep_records',
            headers: request_headers,
            params: valid_params

        json_response = JSON.parse(response.body)
        sleep_data = json_response['data']

        # Extract duration_minutes from each record
        durations = sleep_data.map { |record| record['attributes']['duration_minutes'] }

        # Check that durations are in descending order
        expect(durations).to eq(durations.sort.reverse)
      end
    end

    context 'with invalid parameters' do
      context 'when missing required parameters' do
        it 'returns unprocessable_entity when page is missing' do
          params = valid_params.merge(page: nil)
          get '/api/sleeps/following_users_sleep_records',
              headers: request_headers,
              params: params

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to have_key('messages')
          expect(json_response['error']['messages']).to include(a_string_matching(/Page|page/i))
        end

        it 'returns unprocessable_entity when limit is missing' do
          params = valid_params.merge(limit: nil)
          get '/api/sleeps/following_users_sleep_records',
              headers: request_headers,
              params: params

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to have_key('messages')
          expect(json_response['error']['messages']).to include(a_string_matching(/Limit|limit/i))
        end

        it 'returns unprocessable_entity when date_start is missing' do
          params = valid_params.merge(date_start: nil)
          get '/api/sleeps/following_users_sleep_records',
              headers: request_headers,
              params: params

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to have_key('messages')
          expect(json_response['error']['messages']).to include(a_string_matching(/Date start|date_start/i))
        end

        it 'returns unprocessable_entity when date_end is missing' do
          params = valid_params.merge(date_end: nil)
          get '/api/sleeps/following_users_sleep_records',
              headers: request_headers,
              params: params

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to have_key('messages')
          expect(json_response['error']['messages']).to include(a_string_matching(/Date end|date_end/i))
        end
      end

      context 'when invalid parameter values' do
        it 'returns unprocessable_entity when page is non-positive' do
          params = valid_params.merge(page: 0)
          get '/api/sleeps/following_users_sleep_records',
              headers: request_headers,
              params: params

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to have_key('messages')
          expect(json_response['error']['messages']).to include(a_string_matching(/greater than 0/))
        end

        it 'returns unprocessable_entity when limit is non-positive' do
          params = valid_params.merge(limit: 0)
          get '/api/sleeps/following_users_sleep_records',
              headers: request_headers,
              params: params

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to have_key('messages')
          expect(json_response['error']['messages']).to include(a_string_matching(/greater than 0/))
        end

        it 'returns unprocessable_entity when limit exceeds maximum' do
          params = valid_params.merge(limit: 101)
          get '/api/sleeps/following_users_sleep_records',
              headers: request_headers,
              params: params

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to have_key('messages')
          expect(json_response['error']['messages']).to include(a_string_matching(/less than or equal to 100/))
        end

        it 'returns unprocessable_entity when date_start format is invalid' do
          params = valid_params.merge(date_start: '01-01-2023')  # Wrong format
          get '/api/sleeps/following_users_sleep_records',
              headers: request_headers,
              params: params

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to have_key('messages')
          expect(json_response['error']['messages']).to include(a_string_matching(/format|valid date/i))
        end

        it 'returns unprocessable_entity when date_end format is invalid' do
          params = valid_params.merge(date_end: '01-01-2023')  # Wrong format
          get '/api/sleeps/following_users_sleep_records',
              headers: request_headers,
              params: params

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to have_key('messages')
          expect(json_response['error']['messages']).to include(a_string_matching(/format|valid date/i))
        end

        it 'returns unprocessable_entity when date_start is after date_end' do
          params = valid_params.merge(
            date_start: today.to_s,
            date_end: yesterday.to_s
          )
          get '/api/sleeps/following_users_sleep_records',
              headers: request_headers,
              params: params

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to have_key('messages')
          expect(json_response['error']['messages']).to include(a_string_matching(/before or equal to/))
        end

        it 'returns unprocessable_entity when date range exceeds 3 months' do
          params = valid_params.merge(
            date_start: 4.months.ago.to_date.to_s,
            date_end: today.to_s
          )
          get '/api/sleeps/following_users_sleep_records',
              headers: request_headers,
              params: params

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('error')
          expect(json_response['error']).to have_key('messages')
          expect(json_response['error']['messages']).to include(a_string_matching(/exceed 3 months|date range cannot exceed/i))
        end
      end
    end

    context 'without authentication' do
      it 'returns unauthorized when X-User-Id header is missing' do
        get '/api/sleeps/following_users_sleep_records',
            headers: {},
            params: valid_params

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('error')
        expect(json_response['error']).to have_key('messages')
        expect(json_response['error']['messages']).to include(a_string_matching(/X-User-Id header is required/))
      end

      it 'returns unauthorized when user is not found' do
        invalid_headers = { 'X-User-Id' => 'invalid-uuid' }
        get '/api/sleeps/following_users_sleep_records',
            headers: invalid_headers,
            params: valid_params

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response).to have_key('error')
        expect(json_response['error']).to have_key('messages')
        expect(json_response['error']['messages']).to include(a_string_matching(/User not found/))
      end
    end

    context 'when user follows no one' do
      before do
        # Remove all follow relationships
        Follow.delete_all
      end

      it 'returns empty array' do
        get '/api/sleeps/following_users_sleep_records',
            headers: request_headers,
            params: valid_params

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']).to be_an(Array)
        expect(json_response['data']).to be_empty
      end
    end
  end
end
