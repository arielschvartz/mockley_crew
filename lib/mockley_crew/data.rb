module MockleyCrew
  class Data
    attr_accessor :builders

    def initialize params = []
      raise Errors::InvalidDataError unless params.is_a? Array

      params.each do |p|
        raise Errors::InvalidDataError unless p.is_a? Hash
        
        builders.push FactoryBuilder.new(p)
      end
    end

    def builders
      @builders ||= []
    end

    def save
      success = true
      ActiveRecord::Base.transaction do
        @builders.each do |b|
          unless b.save
            success = false
          end
        end
        raise ActiveRecord::Rollback unless success
      end
      return success
    end

    def as_json
      @builders.map do |b|
        h = {
          "factory" => b.factory,
          "options" => b.options
        }
        unless b.errors.blank?
          h["errors"] = b.errors
        end
        h
      end
    end
  end
end