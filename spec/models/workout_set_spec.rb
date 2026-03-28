require "rails_helper"

RSpec.describe WorkoutSet, type: :model do
  describe "associations" do
    it { expect(described_class.reflect_on_association(:workout_exercise).macro).to eq(:belongs_to) }
  end

  describe "validations" do
    subject { build(:workout_set) }

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "requires set_order" do
      subject.set_order = nil
      expect(subject).not_to be_valid
    end

    it "requires set_order to be positive" do
      subject.set_order = 0
      expect(subject).not_to be_valid
    end

    it "validates weight is not negative" do
      subject.weight = -1
      expect(subject).not_to be_valid
    end

    it "validates rpe range" do
      subject.rpe = 11
      expect(subject).not_to be_valid
    end

    it "allows rpe within range" do
      subject.rpe = 8.5
      expect(subject).to be_valid
    end
  end

  describe "#complete!" do
    it "marks the set as completed" do
      workout_set = create(:workout_set, completed: false)
      workout_set.complete!
      expect(workout_set.completed).to be true
      expect(workout_set.completed_at).to be_present
    end
  end

  describe "#uncomplete!" do
    it "marks the set as not completed" do
      workout_set = create(:workout_set, completed: true, completed_at: Time.current)
      workout_set.uncomplete!
      expect(workout_set.completed).to be false
      expect(workout_set.completed_at).to be_nil
    end
  end
end
