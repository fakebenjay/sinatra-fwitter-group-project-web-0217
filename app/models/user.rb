class User < ActiveRecord::Base
  has_secure_password
  has_many :tweets

  def slug
    self.username.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end

  def self.find_by_slug(slug)
    no_caps = ["the", "with", "a"]
    name_string = slug.split("-").map{|w| w}.join(" ")
    find_by_username(name_string)
  end

end
