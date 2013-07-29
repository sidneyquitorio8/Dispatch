class User < ActiveRecord::Base
  devise 	:ldap_authenticatable, :rememberable, :trackable,
  				:authentication_keys => [:login], :case_insensitive_keys => [:login],
  				:strip_whitespace_keys => [:login]

  validates :cell, :format => { :with => /\A[-+]?[0-9]{11}\z/, :message => "Not a valid 10-digit telephone number" }, :allow_nil => true


  attr_accessible :name, :cell, :email, :pref, :login, :password, :password_confirmation, :remember_me, :send_text, :send_email

  has_many :jobs
  has_many :messages
  has_many :surveys, through: :jobs
  has_many :responses, through: :jobs
  
  before_save :get_ldap_email

  def get_ldap_email 
    self.email = Devise::LdapAdapter.get_ldap_param(self.login,"mail") 
  end

end