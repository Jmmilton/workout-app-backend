require "rails_helper"

RSpec.describe TemplateExercise, type: :model do
  describe "associations" do
    it { expect(described_class.reflect_on_association(:workout_template).macro).to eq(:belongs_to) }
    it { expect(described_class.reflect_on_association(:exercise).macro).to eq(:belongs_to) }
  end

  describe "validations" do
    subject { build(:template_exercise) }

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "requires a position" do
      subject.position = nil
      expect(subject).not_to be_valid
    end

    it "requires position to be positive" do
      subject.position = 0
      expect(subject).not_to be_valid
    end

    it "validates default_weight is not negative" do
      subject.default_weight = -1
      expect(subject).not_to be_valid
    end
  end
end
