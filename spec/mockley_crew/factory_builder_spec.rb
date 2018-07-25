require 'rails_helper'

RSpec.describe MockleyCrew::FactoryBuilder do
  subject { MockleyCrew::FactoryBuilder.new({"factory" => "user"}) }

  it { expect(subject).to respond_to :factory }
  it { expect(subject).to respond_to :options }
  it { expect(subject).to respond_to :errors }

  before(:each) do
    FactoryBot.factories.register(:user, "test")
    FactoryBot.factories.register(:user1, "test")
  end

  after(:each) do
    FactoryBot.factories.clear
  end

  describe "initializer params validation" do
    [
      {"factory" => "user"},
      {"factory" => "user1"},
      {"factory" => "user",
        "options" => { "amount" => 1 }
      },
      {"factory" => "user",
        "options" => { "amount" => "2" }
      },
      {"factory" => "users"},
      {"factory" => "user1s"}
    ].each do |valid_args|
      it "should not raise an error with #{valid_args}" do
        expect {
          MockleyCrew::FactoryBuilder.new(valid_args)
        }.not_to raise_error
      end
    end
    [
      {"teste" => "user1"},
      {"teste" => 1},
      {"teste" => 1}, {"teste1" => 1},
      {"teste" => 1, "teste1" => 1},
      [1, 2, 3],
      ["1", "2", "3"],
      { 1 => 1, 2 => 2 },
      1,
      "teste"
    ].each do |invalid_args|
      it "should raise an error with #{invalid_args}" do
        expect {
          MockleyCrew::FactoryBuilder.new(invalid_args)
        }.to raise_error MockleyCrew::Errors::InvalidDataError
      end
    end

    [
      {"factory" => "user3"},
      {"factory" => "user2"},
      {"factory" => "teste"}
    ].each do |invalid_fac_args|
      it "should raise an error with #{invalid_fac_args}" do
        expect {
          MockleyCrew::FactoryBuilder.new(invalid_fac_args)
        }.to raise_error MockleyCrew::Errors::InvalidFactoryError
      end
    end

    [
      {"factory" => "user", "options" => {"amount" => 0}},
      {"factory" => "user", "options" => {"amount" => -5}}
    ].each do |invalid_amount_args|
      it "should raise an error with #{invalid_amount_args}" do
        expect {
          MockleyCrew::FactoryBuilder.new(invalid_amount_args)
        }.to raise_error MockleyCrew::Errors::InvalidAmountError
      end
    end
  end

  describe "testing the options" do
    describe "default" do
      before(:each) do
        @fb = MockleyCrew::FactoryBuilder.new({"factory" => "user"})
      end

      it "should set the default options" do
        expect(@fb.options).to eq({
          "amount" => 1,
          "attributes" => {}
        })
      end
    end

    describe "partial default" do
      before(:each) do
        @fb = MockleyCrew::FactoryBuilder.new({
          "factory" => "user",
          "options" => {
            "amount" => 2
          }
        })
      end

      it "should set the default options" do
        expect(@fb.options).to eq({
          "amount" => 2,
          "attributes" => {}
        })
      end
    end

    describe "partial default" do
      before(:each) do
        @fb = MockleyCrew::FactoryBuilder.new({
          "factory" => "user",
          "options" => {
            "attributes" => {
              "test" => "test_message"
            }
          }
        })
      end

      it "should set the default options" do
        expect(@fb.options).to eq({
          "amount" => 1,
          "attributes" => {
            "test" => "test_message"
          }
        })
      end
    end

    describe "full data" do
      before(:each) do
        @fb = MockleyCrew::FactoryBuilder.new({
          "factory" => "user",
          "options" => {
            "amount" => 3,
            "attributes" => {
              "test" => "test_message"
            }
          }
        })
      end

      it "should set the default options" do
        expect(@fb.options).to eq({
          "amount" => 3,
          "attributes" => {
            "test" => "test_message"
          }
        })
      end
    end
  end

  describe "save" do
    describe "default" do
      before(:each) do
        @fb = MockleyCrew::FactoryBuilder.new({"factory" => "user"})
      end

      it "should call the FactoryBot create_list method" do
        expect(FactoryBot).to receive(:create_list).with(:user, 1, {})
        @fb.save
      end
    end

    describe "full data" do
      before(:each) do
        @fb = MockleyCrew::FactoryBuilder.new({
          "factory" => "user",
          "options" => {
            "amount" => "3",
            "attributes" => {
              "test" => "test_message"
            }
          }
        })
      end

      it "should call the FactoryBot create_list method" do
        expect(FactoryBot).to receive(:create_list).with(:user, 3, {"test" => "test_message"})
        @fb.save
      end
    end
  end
end