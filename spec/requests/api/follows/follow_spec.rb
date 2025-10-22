require 'rails_helper'

RSpec.describe 'Follow Request', type: :request do
  let(:user) { User.create!(name: 'Test User') }
  let(:target_user) { User.create!(name: 'Target User') }
  let(:other_user) { User.create!(name: 'Other User') }

  describe 'POST /api/follows/follow' do
    context 'when user is authenticated with X-User-Id header' do
      context 'when valid user_id is provided' do
        context 'when target user exists' do
          context 'when user is not trying to follow themselves' do
            context 'when user is not already following target user' do
              it 'successfully follows the target user' do
                expect {
                  post '/api/follows/follow',
                       params: { user_id: target_user.id },
                       headers: { 'X-User-Id' => user.id }
                }.to change(Follow, :count).by(1)

                expect(response).to have_http_status(:ok)
                expect(JSON.parse(response.body)['data']['message']).to eq('Successfully followed user')

                # Verify the follow record was created correctly
                follow = Follow.last
                expect(follow.follower_id).to eq(user.id)
                expect(follow.followed_id).to eq(target_user.id)
              end
            end

            context 'when user is already following target user' do
              before do
                Follow.create!(follower: user, followed: target_user)
              end

              it 'returns unprocessable entity with error message' do
                post '/api/follows/follow',
                     params: { user_id: target_user.id },
                     headers: { 'X-User-Id' => user.id }

                expect(response).to have_http_status(:unprocessable_entity)
                expect(JSON.parse(response.body)['error']['messages']).to include('Already following this user')
              end
            end
          end

          context 'when user tries to follow themselves' do
            it 'returns unprocessable entity with error message' do
              post '/api/follows/follow',
                   params: { user_id: user.id },
                   headers: { 'X-User-Id' => user.id }

              expect(response).to have_http_status(:unprocessable_entity)
              expect(JSON.parse(response.body)['error']['messages']).to include('Cannot follow yourself')
            end
          end
        end

        context 'when target user does not exist' do
          it 'returns unprocessable entity with error message' do
            post '/api/follows/follow',
                 params: { user_id: 'invalid-user-id' },
                 headers: { 'X-User-Id' => user.id }

            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)['error']['messages']).to include('User not found')
          end
        end
      end

      context 'when user_id is not provided' do
        it 'returns unprocessable entity with error message' do
          post '/api/follows/follow',
               headers: { 'X-User-Id' => user.id }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['error']['messages']).to include('User ID is required')
        end
      end

      context 'when user_id is blank' do
        it 'returns unprocessable entity with error message' do
          post '/api/follows/follow',
               params: { user_id: '' },
               headers: { 'X-User-Id' => user.id }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['error']['messages']).to include('User ID is required')
        end
      end
    end

    context 'when X-User-Id header is missing' do
      it 'returns unauthorized status' do
        post '/api/follows/follow',
             params: { user_id: target_user.id }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']['messages']).to include('X-User-Id header is required')
      end
    end

    context 'when user does not exist' do
      it 'returns unauthorized status' do
        post '/api/follows/follow',
             params: { user_id: target_user.id },
             headers: { 'X-User-Id' => 'invalid-uuid' }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']['messages']).to include('User not found')
      end
    end
  end
end
