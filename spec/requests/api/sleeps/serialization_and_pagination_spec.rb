require 'rails_helper'

RSpec.describe 'SleepSerializer and pagination metadata', type: :request do
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

  describe 'GET /api/sleeps/following_users_sleep_records includes user information and pagination metadata' do
    let(:request_headers) { { 'X-User-Id' => user.id } }
    let(:valid_params) do
      {
        page: 1,
        limit: 10,
        date_start: yesterday.to_s,
        date_end: today.to_s
      }
    end

    it 'returns sleep records with user information' do
      get '/api/sleeps/following_users_sleep_records',
          headers: request_headers,
          params: valid_params

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response).to have_key('data')
      expect(json_response['data']).to be_an(Array)

      # Check that each sleep record includes user information
      first_record = json_response['data'].first
      expect(first_record).to have_key('attributes')
      expect(first_record['attributes']).to have_key('user')

      user_info = first_record['attributes']['user']
      expect(user_info).to have_key('id')
      expect(user_info).to have_key('name')

      # Verify user information is correctly included
      expect(user_info['id']).to be_present
      expect(user_info['name']).to be_present
    end

    it 'returns pagination metadata' do
      get '/api/sleeps/following_users_sleep_records',
          headers: request_headers,
          params: valid_params

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      # Check for pagination metadata
      expect(json_response).to have_key('meta')
      meta = json_response['meta']

      expect(meta).to have_key('current_page')
      expect(meta).to have_key('per_page')
      expect(meta).to have_key('offset')
      expect(meta).to have_key('has_next_page')
      expect(meta).to have_key('has_prev_page')

      # Check that values are reasonable
      expect(meta['current_page']).to be >= 1
      expect(meta['per_page']).to be > 0
      expect(meta['offset']).to be >= 0
      expect(meta['has_next_page']).to be_in([ true, false ])
      expect(meta['has_prev_page']).to be_in([ true, false ])
    end

    it 'correctly paginates results' do
      # Create more sleep records to test pagination
      5.times do |i|
        Sleep.create!(
          user: followed_user,
          clock_in_time: (i + 1).hours.ago,
          clock_out_time: (i + 3).hours.ago,
          duration_minutes: (i + 1) * 30
        )
      end

      # Request first page with limit 3
      params = valid_params.merge(limit: 3, page: 1)
      get '/api/sleeps/following_users_sleep_records',
          headers: request_headers,
          params: params

      json_response = JSON.parse(response.body)

      expect(json_response['data'].length).to eq(3)
      expect(json_response['meta']['per_page']).to eq(3)
      expect(json_response['meta']['current_page']).to eq(1)

      # Request second page
      params = valid_params.merge(limit: 3, page: 2)
      get '/api/sleeps/following_users_sleep_records',
          headers: request_headers,
          params: params

      json_response = JSON.parse(response.body)

      expect(json_response['meta']['current_page']).to eq(2)
      expect(json_response['meta']['offset']).to eq(3) # offset should be (page-1)*limit = (2-1)*3
    end
  end
end
