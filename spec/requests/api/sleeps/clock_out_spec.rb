require 'rails_helper'

RSpec.describe 'Clock Out Request', type: :request do
  let(:user) { User.create!(name: 'Test User') }
  let(:other_user) { User.create!(name: 'Other User') }

  describe 'POST /api/sleeps/clock_out' do
    context 'when user is authenticated with X-User-Id header' do
      let!(:sleep_record) { Sleep.create!(user: user, clock_in_time: 2.hours.ago) }

      context 'when valid sleep_id is provided' do
        context 'when sleep record belongs to current user' do
          context 'when sleep record has clock_in_time but no clock_out_time' do
            it 'successfully clocks out the sleep record' do
              expect {
                post '/api/sleeps/clock_out',
                     params: { sleep_id: sleep_record.id },
                     headers: { 'X-User-Id' => user.id }
              }.to change { sleep_record.reload.clock_out_time }.from(nil)

              expect(response).to have_http_status(:ok)
              expect(JSON.parse(response.body)['data']['attributes']['user_id']).to eq(user.id)
              expect(JSON.parse(response.body)['data']['attributes']['clock_out_time']).not_to be_nil
              expect(JSON.parse(response.body)['data']['attributes']['duration_minutes']).to be >= 0
            end
          end

          context 'when sleep record already has clock_out_time' do
            let!(:completed_sleep) { Sleep.create!(user: user, clock_in_time: 3.hours.ago, clock_out_time: 2.hours.ago, duration_minutes: 60) }

            it 'returns unprocessable entity with error message' do
              post '/api/sleeps/clock_out',
                   params: { sleep_id: completed_sleep.id },
                   headers: { 'X-User-Id' => user.id }

              expect(response).to have_http_status(:unprocessable_entity)
              expect(JSON.parse(response.body)['error']['messages']).to include('Clock out time is already set')
            end
          end

          context 'when sleep record does not have clock_in_time' do
            # Create a sleep record without clock_in_time by bypassing validation
            let!(:invalid_sleep) do
              sleep_record = Sleep.new(user: user, clock_out_time: Time.current, duration_minutes: 0)
              sleep_record.save(validate: false) # Bypass validation to create record without clock_in_time
              sleep_record
            end

            it 'returns unprocessable entity with error message' do
              post '/api/sleeps/clock_out',
                   params: { sleep_id: invalid_sleep.id },
                   headers: { 'X-User-Id' => user.id }

              expect(response).to have_http_status(:unprocessable_entity)
              expect(JSON.parse(response.body)['error']['messages']).to include('Clock in time must be present for clock out')
            end
          end
        end

        context 'when sleep record does not belong to current user' do
          let!(:other_sleep) { Sleep.create!(user: other_user, clock_in_time: 1.hour.ago) }

          it 'returns unprocessable entity with error message' do
            post '/api/sleeps/clock_out',
                 params: { sleep_id: other_sleep.id },
                 headers: { 'X-User-Id' => user.id }

            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)['error']['messages']).to include('Sleep record invalid sleep record')
          end
        end
      end

      context 'when sleep_id is not provided' do
        it 'returns not found status' do
          post '/api/sleeps/clock_out',
               headers: { 'X-User-Id' => user.id }

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when sleep record does not exist' do
        it 'returns not found status with error message' do
          post '/api/sleeps/clock_out',
               params: { sleep_id: 'invalid-id' },
               headers: { 'X-User-Id' => user.id }

          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)['error']['messages']).to include('Sleep record not found')
        end
      end
    end

    context 'when X-User-Id header is missing' do
      it 'returns unauthorized status' do
        post '/api/sleeps/clock_out', params: { sleep_id: 'some-id' }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']['messages']).to include('X-User-Id header is required')
      end
    end

    context 'when user does not exist' do
      it 'returns unauthorized status' do
        post '/api/sleeps/clock_out',
             params: { sleep_id: 'some-id' },
             headers: { 'X-User-Id' => 'invalid-uuid' }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']['messages']).to include('User not found')
      end
    end
  end
end
