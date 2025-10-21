# Testing Setup

This project uses RSpec for testing, configured with the following gems:

## Gems

- **rspec-rails**: The core RSpec testing framework for Rails applications
- **shoulda-matchers**: Provides additional RSpec matchers for testing common Rails functionality
- **rubocop-rspec**: RuboCop extension for enforcing RSpec best practices
- **kaminari**: Pagination gem
- **jsonapi-serializer**: JSON API serialization gem
- **redis**: Redis client for caching and background jobs

## Running Tests

```bash
# Run all tests
bundle exec rspec

# Run tests in a specific directory
bundle exec rspec spec/models

# Run a specific test file
bundle exec rspec spec/models/user_spec.rb

# Run tests with documentation format
bundle exec rspec --format documentation
```

## Basic Configuration

- Models, controllers, mailers, and other Rails components are automatically mapped to their respective spec types based on file location
- Transactional fixtures are enabled to ensure clean test data
- Database schema is maintained automatically in test environment
- Tests run in random order to detect dependencies
- Focused tests can be run using `:focus` tag

## Example Test Structure

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }
  it { should have_many(:posts) }
  
  it 'has a valid factory' do
    user = FactoryBot.create(:user)
    expect(user).to be_valid
  end
end
```