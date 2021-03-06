class User < ActiveRecord::Base
  attr_accessor :password
  EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i

  validates :username, presence: true, uniqueness: true, length: { in: 3..20 }
  validates :email, presence: true, uniqueness: true, format: EMAIL_REGEX
  validates :password, presence: true, length: { in: 6..20, on: :create }

  before_save :encrypt_password
  after_save :clear_password

  def encrypt_password
    return unless password.present?
    self.salt = BCrypt::Engine.generate_salt
    self.encrypted_password = BCrypt::Engine.hash_secret(password, salt)
  end

  def clear_password
    self.password = nil
  end

  # Authenticate user login
  def self.authenticate(username_or_email = '', login_password = '')
    user = by_username_or_email(username_or_email)

    if user && user.match_password(login_password)
      return user
    else
      return false
    end
  end

  # Find a user by username or email
  def self.by_username_or_email(username_or_email = '')
    if EMAIL_REGEX.match(username_or_email)
      User.find_by_email(username_or_email)
    else
      User.find_by_username(username_or_email)
    end
  end

  # Method for matching passwords
  def match_password(login_password = '')
    encrypted_password == BCrypt::Engine.hash_secret(login_password, salt)
  end
end
