class User < ActiveRecord::Base
  default_scope :order => 'created_at desc'

  acts_as_authentic
  has_one :registration
  has_many :votes

  has_many :speakers
  has_many :talks, :through => :speakers

  has_many :comments

  attr_protected :crypted_password, :password_salt, :persistence_token, :created_at, :updated_at,
  	:login_count, :failed_login_count, :last_request_at, :current_login_at, :current_login_ip, :last_login_ip

  accepts_nested_attributes_for :registration

  validates_format_of :phone_number, :with => /\A(\d{8}|\d{3} \d{2} ?\d{3}|\d{2} \d{2} \d{2} \d{2}|\(\+\d+\)[\d ]+)\Z/,
    :message => "må være på formen 99999999 eller (+99) 999999...", :allow_nil => true
  validates_length_of :phone_number, :in => 8..30

  validates_presence_of :name
  validates_uniqueness_of :email
  validates_each :accepted_privacy_guidelines do |record, attr, value|
    record.errors.add attr, 'Du må godta at vi sender deg epost om konferansen.' if value == false
  end

  def user_status
    registration ? registration.description : "Ukjent"
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    SmidigMailer.deliver_password_reset_instructions(self)
  end


  def self.find_with_filter(filter)
    case filter
    when "all","", nil
      return find(:all, :include => :registration)
    when "admin"
      return find(:all, :conditions => { :is_admin => true }, :include => :registration)
    when "speakers"
      return find(:all, :include => [:registration, :talks]).reject { |u| u.talks.empty? }
    when "paid"
      return find(:all, :include => :registration).select { |u| u.registration and u.registration.paid? }
    when "unpaid"
      return find(:all, :include => :registration).select { |u| u.registration and not u.registration.paid? and u.talks.empty? }
    when "volunteer"
      return find(:all, :include => :registration).select { |u| u.registration and u.registration.ticket_type == "volunteer" }
    when "paying_speaker"
      return find(:all, :include => [:registration, :talks]).reject { |u| u.talks.empty? }.
        select { |u| u.registration and u.registration.paid? }
    else
      raise "Illegal filter #{filter}"
    end
  end

end
