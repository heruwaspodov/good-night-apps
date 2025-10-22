require 'rails_helper'

RSpec.describe 'Unfollow Request', type: :request do
  let(:user) { User.create!(name: 'Test User') }
  let(:target_user) { User.create!(name: 'Target User') }
  let(:other_user) { User.create!(name: 'Other User') }

  describe 'POST /api/follows/unfollow' do
    context 'when user is authenticated with X-User-Id header' do
      context 'when valid user_id is provided' do
        context 'when target user exists' do
          context 'when user is not trying to unfollow themselves' do
            context 'when user is already following target user' do
              before do
                Follow.create!(follower: user, followed: target_user)
              end

              it 'successfully unfollows the target user' do
                expect {
                  post '/api/follows/unfollow',
                       params: { user_id: target_user.id },
                       headers: { 'X-User-Id' => user.id }
                }.to change(Follow, :count).by(-1)

                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)['data']['message']).to eq('Successfully unfollowed user')
              end
            end

            context 'when user is not following target user' do
              it 'returns unprocessable entity with error message' do
                post '/api/follows/unfollow',
                     params: { user_id: target_user.id },
                     headers: { 'X-User-Id' => user.id }

                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)['error']['messages']).to include('Not following this user')
              end
            end
          end

          context 'when user tries to unfollow themselves' do
            it 'returns unprocessable entity with error message' do
              post '/api/follows/unfollow',
                   params: { user_id: user.id },
                   headers: { 'X-User-Id' => user.id }

              expect(response).to have_http_status(:unprocessable_entity)
              expect(JSON.parse(response.body)['error']['messages']).to include('Cannot unfollow yourself')
            end
          end
        end

        context 'when target user does not exist' do
          it 'returns unprocessable entity with error message' do
            post '/api/follows/unfollow',
                 params: { user_id: 'invalid-user-id' },
                 headers: { 'X-User-Id' => user.id }

            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)['error']['messages']).to include('User not found')
          end
        end
      end

      context 'when user_id is not provided' do
        it 'returns unprocessable entity with error message' do
          post '/api/follows/unfollow',
               headers: { 'X-User-Id' => user.id }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['error']['messages']).to include('User ID is required')
        end
      end

      context 'when user_id is blank' do
        it 'returns unprocessable entity with error message' do
          post '/api/follows/unfollow',
               params: { user_id: '' },
               headers: { 'X-User-Id' => user.id }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['error']['messages']).to include('User ID is required')
        end
      end
    end

    context 'when X-User-Id header is missing' do
      it 'returns unauthorized status' do
        post '/api/follows/unfollow',
             params: { user_id: target_user.id }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']['messages']).to include('X-User-Id header is required')
      end
    end

    context 'when user does not exist' do
      it 'returns unauthorized status' do
        post '/api/follows/unfollow',
             params: { user_id: target_user.id },
             headers: { 'X-User-Id' => 'invalid-uuid' }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']['messages']).to include('User not found')
      end
    end
  end
end
