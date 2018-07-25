require 'rails_helper'

RSpec.describe MockleyCrew::Data do
  subject { MockleyCrew::Data.new }

  it { expect(subject).to respond_to :builders }
  it { expect(subject).to respond_to :save }
  it { expect(subject).to respond_to :as_json }

  before(:each) do
    FactoryBot.factories.register(:user, "test")
    FactoryBot.factories.register(:user1, "test")
  end

  after(:each) do
    FactoryBot.factories.clear
  end

  describe "initializer params validation" do
    [
      [{"factory" => "user"}],
      [{"factory" => "user"}, {"factory" => "user1"}],
      [{"factory" => "user", "teste" => 1}]
    ].each do |valid_args|
      it "should not raise an error with #{valid_args}" do
        expect {
          MockleyCrew::Data.new(valid_args)
        }.not_to raise_error
      end
    end
    [
      [{"factory" => "user"}, {"teste" => "user1"}],
      [{"teste" => 1}],
      [{"teste" => 1}, {"teste1" => 1}],
      [{"teste" => 1, "teste1" => 1}],
      [1, 2, 3],
      ["1", "2", "3"],
      { 1 => 1, 2 => 2 },
      1,
      "teste"
    ].each do |invalid_args|
      it "should raise an error with #{invalid_args}" do
        expect {
          MockleyCrew::Data.new(invalid_args)
        }.to raise_error MockleyCrew::Errors::InvalidDataError
      end
    end

    [
      [{"factory" => "user"}, {"factory" => "user2"}]
    ].each do |invalid_fac_args|
      it "should raise an error with #{invalid_fac_args}" do
        expect {
          MockleyCrew::Data.new(invalid_fac_args)
        }.to raise_error MockleyCrew::Errors::InvalidFactoryError
      end
    end
  end

  describe "builders" do
    before(:each) do
      @data = MockleyCrew::Data.new([
        {
          "factory" => "user",
          "options" => {
            "amount" => "2"
          }
        },
        {
          "factory" => "user1"
        },
        {
          "factory" => "user1",
          "options" => {
            "attributes" => {
              "name" => "test"
            }
          }
        }
      ])
    end

    it "should create the correct builders" do
      expect(@data.builders.length).to eq(3)
      expect(@data.builders.map { |x| x.factory }).to match_array(["user", "user1", "user1"])
    end

    describe "as_json" do
      it "should be correct" do
        expect(@data.as_json).to eq([
          {
            "factory" => "user",
            "options" => {
              "amount" => "2",
              "attributes" => {}
            }
          },
          {
            "factory" => "user1",
            "options" => {
              "amount" => 1,
              "attributes" => {}
            }
          },
          {
            "factory" => "user1",
            "options" => {
              "amount" => 1,
              "attributes" => { "name" => "test" }
            }
          }
        ])
      end

      describe "when there are errors" do
        before(:each) do
          @data.builders.first.errors["test"] = "test error"
        end

        it "should be correct" do
          expect(@data.as_json).to eq([
            {
              "factory" => "user",
              "options" => {
                "amount" => "2",
                "attributes" => {}
              },
              "errors" => {
                "test" => "test error"
              }
            },
            {
              "factory" => "user1",
              "options" => {
                "amount" => 1,
                "attributes" => {}
              }
            },
            {
              "factory" => "user1",
              "options" => {
                "amount" => 1,
                "attributes" => { "name" => "test" }
              }
            }
          ])
        end
      end
    end
  end
end