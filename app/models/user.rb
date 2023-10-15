class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: %i[google_oauth2]

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :authorizations, dependent: :destroy

  def self.from_omniauth(access_token)
    data = extract_info(access_token)
    user = find_by_email(data['email'])
  
    unless user
      user = create_user(data)
    end
  
    # Save the tokens to the user's Authorization record
    authorization = user.authorizations.find_or_initialize_by(provider: access_token.provider, uid: access_token.uid)
    authorization.access_token = access_token.credentials.token
    authorization.refresh_token = access_token.credentials.refresh_token # refresh_token may be nil
    authorization.save
  
    user
  end

  def self.extract_info(access_token)
    access_token.info
  end
  
  def self.find_by_email(email)
    User.where(email: email).first
  end
  
  def self.create_user(data)
    transaction do
      User.create(
      name: data['name'],
      email: data['email'],
      password: Devise.friendly_token[0,20]
      )
    end  
  end

end
