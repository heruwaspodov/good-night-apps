require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:sleeps).dependent(:destroy) }
    it { is_expected.to have_many(:daily_sleep_summaries).dependent(:destroy) }
    it { is_expected.to have_many(:active_follows).class_name('Follow').with_foreign_key('follower_id').dependent(:destroy) }
    it { is_expected.to have_many(:passive_follows).class_name('Follow').with_foreign_key('followed_id').dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'db indexes' do
    it { is_expected.to have_db_index(:name) }
  end
end
