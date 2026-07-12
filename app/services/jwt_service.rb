class JwtService
    SECRET_KEY = Rails.application.credentials.dig(:jwt_secret).to_s
    def self.encode(payload)
        JWT.encode(payload, SECRET_KEY, "HS256")
    end

    def self.decode(token)
        decoded = JWT.decode(token, SECRET_KEY, true, algorithm: "HS256")[0]
        HashWithIndifferentAccess.new(decoded)
    rescue JWT::DecodeError => e
        raise StandardError.new("Invalid token: #{e.message}")
    end
end
