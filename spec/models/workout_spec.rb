require "rails_helper"

RSpec.describe Workout, type: :model do
  describe "associations" do
    it { expect(described_class.reflect_on_association(:workout_template).macro).to eq(:belongs_to) }
    it { expect(described_class.reflect_on_association(:workout_exercises).macro).to eq(:has_many) }
    it { expect(described_class.reflect_on_association(:workout_sets).macro).to eq(:has_many) }
  end

  describe "validations" do
    subject { build(:workout) }

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "requires a name" do
      subject.name = nil
      expect(subject).not_to be_valid
    end

    it "requires a user_id" do
      subject.user_id = nil
      expect(subject).not_to be_valid
    end

    it "requires started_at" do
      subject.started_at = nil
      expect(subject).not_to be_valid
    end

    it "validates status inclusion" do
      subject.status = "invalid"
      expect(subject).not_to be_valid
    end

    it "allows nil workout_template" do
      subject.workout_template = nil
      expect(subject).to be_valid
    end
  end

  describe "scopes" do
    before do
      create(:workout, status: "active")
      create(:workout, :completed)
      create(:workout, :cancelled)
    end

    it "filters active workouts" do
      user_id = AuthHelpers::TEST_USER_ID
      expect(Workout.active.where(user_id: user_id).count).to eq(1)
    end

    it "filters completed workouts" do
      user_id = AuthHelpers::TEST_USER_ID
      expect(Workout.completed.where(user_id: user_id).count).to eq(1)
    end
  end

  describe "#complete!" do
    it "sets status to completed with duration" do
      workout = create(:workout, started_at: 1.hour.ago)
      workout.complete!
      expect(workout.status).to eq("completed")
      expect(workout.completed_at).to be_present
      expect(workout.duration_seconds).to be_within(5).of(3600)
    end
  end

  describe "#cancel!" do
    it "sets status to cancelled" do
      workout = create(:workout)
      workout.cancel!
      expect(workout.status).to eq("cancelled")
      expect(workout.completed_at).to be_present
    end
  end
end
