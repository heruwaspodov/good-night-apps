require 'rails_helper'

RSpec.describe Api::SleepsController, type: :controller do
  let(:user) { User.create!(name: 'Test User') }

  describe 'POST #clock_in' do
    context 'when user is authenticated with X-User-Id header' do
      before do
        request.headers['X-User-Id'] = user.id
      end

      context 'when user does not have an active clock-in' do
        it 'creates a new sleep record with clock_in_time' do
          expect {
            post :clock_in
          }.to change(Sleep, :count).by(1)

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['data']['attributes']['user_id']).to eq(user.id)
          expect(JSON.parse(response.body)['data']['attributes']['clock_in_time']).not_to be_nil
        end
      end

      context 'when user already has an active clock-in' do
        before do
          Sleep.create!(user: user, clock_in_time: Time.current)
        end

        it 'returns forbidden status with error message' do
          post :clock_in

          expect(response).to have_http_status(:forbidden)
          expect(JSON.parse(response.body)['error']['messages']).to include('User must clock out before clocking in again')
        end
      end
    end

    context 'when X-User-Id header is missing' do
      it 'returns unauthorized status' do
        post :clock_in

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']['messages']).to include('X-User-Id header is required')
      end
    end

    context 'when user does not exist' do
      before do
        request.headers['X-User-Id'] = 'invalid-uuid'
      end

      it 'returns unauthorized status' do
        post :clock_in

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']['messages']).to include('User not found')
      end
    end
  end
end
