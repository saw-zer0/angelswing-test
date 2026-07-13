require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it 'uses the PasswordStrengthValidator for passwords' do
      expect(User.validators).to include(an_instance_of(PasswordStrengthValidator))
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:contents).dependent(:destroy) }
  end
end
