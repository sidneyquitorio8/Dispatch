class AuthorizedRunner < ActiveRecord::Base
  attr_accessible :login

  validates :login, :presence => true

end
