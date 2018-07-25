module FactoryHelpers
  def define_user_class
    return if defined?(User)
    klass = Class.new do
      def self.name
        "User"
      end

      def save
        if name.blank?
          raise ActiveRecord::RecordInvalid
        else
          true
        end
      end
      alias_method :save!, :save

      attr_accessor :name
    end

    Object.const_set("User", klass)
  end

  def register_user_factories
    FactoryBot.define do
      factory :user do
        name "Test"
      end

      factory :user1, class: "User" do
        name "Test1"
      end
    end
  end
end