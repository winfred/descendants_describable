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

class Model < ActiveRecord::Base
  include DescendantsDescribable

  describe_descendants_with(Models::Descriptors) do
    walks_like_a_duck do
      type :badger
      type :hadger do
        is_a_witch
      end

      floats_like_a_duck do
        type :tadger
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
end

describe DescendantsDescribable do

  describe '.type - for subclass generation' do
    it 'creates new subclass of each type' do
      [Badger, Hadger, Fadger, Ladger, Tadger].each do |klass|
        expect(klass < Model).to be_true
      end
    end
  end

  describe 'dynamic module name methods' do
    subject { DescendantsDescribable::DescendantsDescriptor.new(Model, Models::Descriptors) }
    it { should respond_to(:is_a_witch) }

    it 'includes module into new class' do
      expect(Badger < Models::Descriptors::WalksLikeADuck).to be_true
      expect(Hadger < Models::Descriptors::IsAWitch).to be_true
      expect(Fadger < Models::Descriptors::TalksLikeADuck).to be_true
      expect(Ladger < Models::Descriptors::FloatsLikeADuck).to be_true
      expect(Ladger < Models::Descriptors::TalksLikeADuck).to be_true
      expect(Ladger < Models::Descriptors::IsAWitch).to be_true

      expect(Tadger < Models::Descriptors::FloatsLikeADuck).to be_true
      expect(Tadger < Models::Descriptors::WalksLikeADuck).to be_true
      expect(Tadger < Models::Descriptors::TalksLikeADuck).to be_true

      expect(Madger < Models::Descriptors::WalksLikeADuck).to be_true
      expect(Madger < Models::Descriptors::IsAWitch).to be_true
    end
  end
end