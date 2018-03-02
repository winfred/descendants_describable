require 'spec_helper'

module Models
  module Descriptors
    module WalksLikeADuck
    end

    module TalksLikeADuck
    end

    module FloatsLikeADuck
    end

    module IsAWitch
    end
  end
end

# in your model
class Model < ActiveRecord::Base
  include DescendantsDescribable

  def self.description(description = nil)
    @description ||= description
  end
end

# in config/initializers/#{name_of_model}}.rb
Model.describe_descendants_with(Models::Descriptors) do
  walks_like_a_duck do
    type :badger
    type :hadger do
      is_a_witch
    end

    floats_like_a_duck do
      type :tadger do
        description 'used to indicate true duckiness'
      end
    end

    is_a_witch do
      type :madger
    end
  end

  talks_like_a_duck do
    type :fadger

    floats_like_a_duck do
      type :ladger do
        is_a_witch
      end
      type :tadger
    end
  end
end

describe DescendantsDescribable do
  describe '.type - for subclass generation' do
    it 'creates new subclass of each type' do
      [Badger, Hadger, Fadger, Ladger, Tadger].each do |klass|
        expect(klass < Model).to be_truthy
      end
    end
  end

  describe 'dynamic module name methods' do
    subject { DescendantsDescribable::DescendantsDescriptor.new(Model, Models::Descriptors) }
    it { should respond_to(:is_a_witch) }

    it 'includes module into new class' do
      expect(Badger < Models::Descriptors::WalksLikeADuck).to be_truthy
      expect(Hadger < Models::Descriptors::IsAWitch).to be_truthy
      expect(Fadger < Models::Descriptors::TalksLikeADuck).to be_truthy
      expect(Ladger < Models::Descriptors::FloatsLikeADuck).to be_truthy
      expect(Ladger < Models::Descriptors::TalksLikeADuck).to be_truthy
      expect(Ladger < Models::Descriptors::IsAWitch).to be_truthy

      expect(Tadger < Models::Descriptors::FloatsLikeADuck).to be_truthy
      expect(Tadger < Models::Descriptors::WalksLikeADuck).to be_truthy
      expect(Tadger < Models::Descriptors::TalksLikeADuck).to be_truthy

      expect(Madger < Models::Descriptors::WalksLikeADuck).to be_truthy
      expect(Madger < Models::Descriptors::IsAWitch).to be_truthy

      expect(Tadger.description).to eql('used to indicate true duckiness')
    end
  end
end