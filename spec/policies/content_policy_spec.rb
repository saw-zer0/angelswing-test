require 'rails_helper'

RSpec.describe ContentPolicy, type: :policy do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:content) { create(:content, user: owner) }

  subject(:policy) { described_class.new(user, content) }

  context "when the user is the owner" do
    let(:user) { owner }

    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(true) }
    it { expect(policy.destroy?).to be(true) }
  end

  context "when the user is not the owner" do
    let(:user) { other_user }

    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(true) }
    it { expect(policy.update?).to be(false) }
    it { expect(policy.destroy?).to be(false) }
  end

  context "when the user is nil" do
    let(:user) { nil }

    it { expect(policy.show?).to be(true) }
    it { expect(policy.create?).to be(false) }
    it { expect(policy.update?).to be(false) }
    it { expect(policy.destroy?).to be(false) }
  end
end
