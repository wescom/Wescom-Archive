class User < ActiveRecord::Base
  include Adauth::Rails::ModelBridge

  AdauthMappings = {
      :login => :login,
      :group_strings => :cn_groups,
      :ou_strings => :dn_ous,
      :name => :name
  }

  AdauthSearchField = [:login, :login]
  
#  def self.create_with_openid(identity, openid_params)
#    create! do |user|
#      user.identity = identity
#      user.email = openid_params["http://axschema.org/contact/email"].first
#      user.first_name = openid_params["http://axschema.org/namePerson/first"].first
#      user.last_name = openid_params["http://axschema.org/namePerson/last"].first
#      user.role = "View"
#    end
#  end
end
