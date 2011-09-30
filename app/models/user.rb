class User < ActiveRecord::Base
  def self.create_with_openid(identity, openid_params)
    create! do |user|
      user.identity = identity
      user.email = openid_params["http://axschema.org/contact/email"].first
      user.first_name = openid_params["http://axschema.org/namePerson/first"].first
      user.last_name = openid_params["http://axschema.org/namePerson/last"].first
    end
  end
end
