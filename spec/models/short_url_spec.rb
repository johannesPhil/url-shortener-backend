require 'rails_helper'

RSpec.describe ShortUrl, type: :model do
  # Create a default instance of ShortUrl with an unsaved object
  subject { FactoryBot.build(:short_url) }

  describe 'Validations' do
    subject.original_url = nil
    subject.slug = nil

    it 'validates presence of original_url' do
      expect(subject).to be_invalid
    end

    it 'validates presence of slug' do
      expect(subject).to be_invalid
    end

    context 'slug uniqueness' do
      let!(:existing_url) { FactoryBot.create(:short_url, slug: 'test-slug') }

      let(:new_url) { FactoryBot.build(:short_url, slug: 'test-slug') }

      let(:unique_url) { FactoryBot.build(:short_url, slug: 'unique-slug') }

      it 'is invalid when slug is not unique' do
        expect(new_url).to be_invalid
        expect(new_url.errors[:slug]).to include('has already been taken')
      end
      it 'is valid when slug is unique' do
        expect(unique_url).to be_valid
      end
    end

    context 'visits' do
      it 'is valid when visists value is an integer' do
        subject.visits = 10
        expect(subject).to be_valid
      end

      it 'is invalid when visists value is not an integer' do
        subject.visits = 'ten'
        expect(subject).to be_invalid
        expect(subject.errors[:visits]).to include('must be a number')
      end
    end
  end
end
