# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: %i[google_oauth2]

  # devise :database_authenticatable, :registerable,
  #        :recoverable, :rememberable, :validatable

  has_many :authorizations, dependent: :destroy
  has_many :study_records, dependent: :destroy

  def self.from_omniauth(auth)
    data = auth.info
    user = User.where(email: data['email']).first

    user ||= User.create(name: data['name'], email: data['email'],
                         custom_token: Devise.friendly_token[0, 20])
    authorization = user.authorizations.find_or_create_by(provider: auth.provider, uid: auth.uid)
    authorization.save

    user
  end

  def all_tags
    dashboards.joins(:tags).select('tags.*').distinct
  end

  # 　タグごとの勉強時間を計算
  def tag_total_time
    dashboards.joins(:tags).group('tags.name').sum('dashboards.total_time')
  end
end
