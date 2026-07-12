class User < ApplicationRecord
    has_many :contents, dependent: :destroy
    has_secure_password

    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, 
        presence: true, 
        uniqueness: true, 
        format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, 
        password_strength: true # Custom validator from app/validators/password_strength_validator.rb
end
