require "rails_helper"

RSpec.describe Exercise, type: :model do
  describe "associations" do
    it { expect(described_class.reflect_on_association(:template_exercises).macro).to eq(:has_many) }
    it { expect(described_class.reflect_on_association(:workout_exercises).macro).to eq(:has_many) }
    it { expect(described_class.reflect_on_association(:workout_templates).macro).to eq(:has_many) }
  end

  describe "validations" do
    subject { build(:exercise) }

    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "requires a name" do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it "requires a user_id" do
      subject.user_id = nil
      expect(subject).not_to be_valid
    end

    it "enforces uniqueness of name per user" do
      create(:exercise, name: "Bench Press", user_id: subject.user_id)
      subject.name = "Bench Press"
      expect(subject).not_to be_valid
    end

    it "allows same name for different users" do
      create(:exercise, name: "Bench Press", user_id: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
      subject.name = "Bench Press"
      expect(subject).to be_valid
    end

    it "validates muscle_group inclusion" do
      subject.muscle_group = "invalid"
      expect(subject).not_to be_valid
    end

    it "allows blank muscle_group" do
      subject.muscle_group = nil
      expect(subject).to be_valid
    end

    it "validates equipment_type inclusion" do
      subject.equipment_type = "invalid"
      expect(subject).not_to be_valid
    end

    it "allows blank equipment_type" do
      subject.equipment_type = nil
      expect(subject).to be_valid
    end
  end
end
