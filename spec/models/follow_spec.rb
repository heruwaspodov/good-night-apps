require 'rails_helper'

RSpec.describe Follow, type: :model do
  let(:follower) { User.create!(name: 'Follower') }
  let(:followed) { User.create!(name: 'Followed') }

  describe 'associations' do
    it { is_expected.to belong_to(:follower).class_name('User') }
    it { is_expected.to belong_to(:followed).class_name('User') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:follower_id) }
    it { is_expected.to validate_presence_of(:followed_id) }

    # Skip the uniqueness validation test that doesn't work well with UUIDs in test environment
    # it { is_expected.to validate_uniqueness_of(:follower_id).scoped_to(:followed_id) }
  end

  describe 'db indexes' do
    it { is_expected.to have_db_index([ :follower_id, :followed_id ]).unique(true) }
  end

  describe 'custom validation' do
    it 'does not allow user to follow themselves' do
      follow = described_class.new(follower: follower, followed: follower)
      expect(follow).not_to be_valid
    end

    it 'adds error when user tries to follow themselves' do
      follow = described_class.new(follower: follower, followed: follower)
      follow.valid?
      expect(follow.errors[:followed_id]).to include("can't be the same as follower")
    end

    it 'allows user to follow another user' do
      follow = described_class.new(follower: follower, followed: followed)
      expect(follow).to be_valid
    end
  end

  # Add a custom test for uniqueness since the standard validation test doesn't work with UUIDs
  describe 'uniqueness validation' do
    it 'validates uniqueness of follower_id scoped to followed_id' do
      follower = User.create!(name: 'Follower')
      followed = User.create!(name: 'Followed')

      # Create the first follow relationship
      described_class.create!(follower: follower, followed: followed)

      # Try to create the same follow relationship again
      duplicate_follow = described_class.new(follower: follower, followed: followed)
      expect(duplicate_follow).not_to be_valid
    end
  end
end
