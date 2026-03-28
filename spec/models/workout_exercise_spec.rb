require "rails_helper"

RSpec.describe WorkoutExercise, type: :model do
  describe "associations" do
    it { expect(described_class.reflect_on_association(:workout).macro).to eq(:belongs_to) }
    it { expect(described_class.reflect_on_association(:exercise).macro).to eq(:belongs_to) }
    it { expect(described_class.reflect_on_association(:workout_sets).macro).to eq(:has_many) }
  end

  describe "validations" do
    subject { build(:workout_exercise) }

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
  end
end
