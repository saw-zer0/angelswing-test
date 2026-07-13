class Api::V1::UserSerializer
  include JSONAPI::Serializer
  set_key_transform :camel_lower

  attributes :email

  attribute :name do |user|
    "#{user.first_name} #{user.last_name}"
  end

  attribute :country, :created_at, :updated_at
end
