require 'rails_helper'

RSpec.describe FollowingUsersSleepRecordsValidator, type: :model do
  describe 'validations' do
    subject(:validator) { described_class.new(params) }

    context 'with valid parameters' do
      let(:params) do
        {
          page: 1,
          limit: 10,
          date_start: '2023-01-01',
          date_end: '2023-01-07'
        }
      end

      it 'is valid with correct parameters' do
        expect(validator).to be_valid
      end

      it 'is valid when date range is exactly 3 months' do
        params[:date_start] = '2023-01-01'
        params[:date_end] = '2023-04-01'  # Exactly 3 months later
        expect(validator).to be_valid
      end
    end

    context 'with invalid parameters' do
      let(:params) { {} }

      it 'is invalid without page' do
        params[:page] = nil
        params[:limit] = 10
        params[:date_start] = '2023-01-01'
        params[:date_end] = '2023-01-07'
        expect(validator).not_to be_valid
        expect(validator.errors[:page]).to include("can't be blank")
      end

      it 'is invalid with non-positive page value' do
        params[:page] = 0
        params[:limit] = 10
        params[:date_start] = '2023-01-01'
        params[:date_end] = '2023-01-07'
        expect(validator).not_to be_valid
        expect(validator.errors[:page]).to include("must be greater than 0")
      end

      it 'is invalid without limit' do
        params[:page] = 1
        params[:limit] = nil
        params[:date_start] = '2023-01-01'
        params[:date_end] = '2023-01-07'
        expect(validator).not_to be_valid
        expect(validator.errors[:limit]).to include("can't be blank")
      end

      it 'is invalid with non-positive limit value' do
        params[:page] = 1
        params[:limit] = 0
        params[:date_start] = '2023-01-01'
        params[:date_end] = '2023-01-07'
        expect(validator).not_to be_valid
        expect(validator.errors[:limit]).to include("must be greater than 0")
      end

      it 'is invalid with limit exceeding maximum' do
        params[:page] = 1
        params[:limit] = 101
        params[:date_start] = '2023-01-01'
        params[:date_end] = '2023-01-07'
        expect(validator).not_to be_valid
        expect(validator.errors[:limit]).to include("must be less than or equal to 100")
      end

      it 'is invalid without date_start' do
        params[:page] = 1
        params[:limit] = 10
        params[:date_start] = nil
        params[:date_end] = '2023-01-07'
        expect(validator).not_to be_valid
        expect(validator.errors[:date_start]).to include("can't be blank")
      end

      it 'is invalid without date_end' do
        params[:page] = 1
        params[:limit] = 10
        params[:date_start] = '2023-01-01'
        params[:date_end] = nil
        expect(validator).not_to be_valid
        expect(validator.errors[:date_end]).to include("can't be blank")
      end

      it 'is invalid when date_start format is wrong' do
        params[:page] = 1
        params[:limit] = 10
        params[:date_start] = '01-01-2023'  # Wrong format
        params[:date_end] = '2023-01-07'
        expect(validator).not_to be_valid
        expect(validator.errors[:date_start]).to include("must be in YYYY-MM-DD format")
      end

      it 'is invalid when date_end format is wrong' do
        params[:page] = 1
        params[:limit] = 10
        params[:date_start] = '2023-01-01'
        params[:date_end] = '07-01-2023'  # Wrong format
        expect(validator).not_to be_valid
        expect(validator.errors[:date_end]).to include("must be in YYYY-MM-DD format")
      end

      it 'is invalid when date_start is after date_end' do
        params[:page] = 1
        params[:limit] = 10
        params[:date_start] = '2023-01-10'
        params[:date_end] = '2023-01-01'
        expect(validator).not_to be_valid
        expect(validator.errors[:date_start]).to include("must be before or equal to date_end")
      end

      it 'is invalid when date range exceeds 3 months' do
        params[:page] = 1
        params[:limit] = 10
        params[:date_start] = '2023-01-01'
        params[:date_end] = '2023-05-01'  # More than 3 months
        expect(validator).not_to be_valid
        expect(validator.errors[:date_end]).to include("date range cannot exceed 3 months")
      end

      it 'is invalid with invalid date values' do
        params[:page] = 1
        params[:limit] = 10
        params[:date_start] = '2023-02-30'  # Invalid date
        params[:date_end] = '2023-02-28'
        expect(validator).not_to be_valid
        expect(validator.errors[:date_start]).to include("must be a valid date in YYYY-MM-DD format")
      end
    end
  end
end
