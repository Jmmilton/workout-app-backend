require "rails_helper"

RSpec.describe WorkoutTemplate, type: :model do
  describe "associations" do
    it { expect(described_class.reflect_on_association(:template_exercises).macro).to eq(:has_many) }
    it { expect(described_class.reflect_on_association(:exercises).macro).to eq(:has_many) }
    it { expect(described_class.reflect_on_association(:workouts).macro).to eq(:has_many) }
  end

  describe "validations" do
    subject { build(:workout_template) }

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
  end

  describe "nested attributes" do
    it "accepts nested template_exercises" do
      exercise = create(:exercise)
      template = build(:workout_template, template_exercises_attributes: [
        { exercise_id: exercise.id, position: 1, default_sets: 3, default_reps: 10 }
      ])
      expect(template.save).to be true
      expect(template.template_exercises.count).to eq(1)
    end
  end
end
