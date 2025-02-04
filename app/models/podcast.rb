class Podcast < ApplicationRecord
  has_one_attached :photo
  has_one_attached :audio

  validates :title, presence: true
  validates :title, length: { minimum: 2 }

  def self.random_by_day
    return unless exists?

    cached_random_podcast_id = Rails.cache.fetch("random_podcast_id", expires_in: 1.days) do
      offset(rand(Podcast.count)).first.id
    end
    find_by(id: cached_random_podcast_id)
  end
end
