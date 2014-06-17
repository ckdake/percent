require 'oauth2'

class NerdRepository
  Nerd = Struct.new(:full_name, :hire_date, :active, :updated_at)

  def initialize(access_token)
    @access_token = access_token
  end

  def all
    @all ||= all_nerds.map do |nerd|
      Nerd.new(
        nerd["full_name"],
        nerd["hire_date"].blank? ? "" : Date.parse(nerd["hire_date"]),
        nerd["active"],
        Date.parse(nerd["updated_at"]),
      )
    end
  end

  def active
    @active ||= active_nerds.map do |nerd|
      Nerd.new(
        nerd["full_name"],
        nerd["hire_date"].blank? ? "" : Date.parse(nerd["hire_date"]),
        nerd["active"],
        Date.parse(nerd["updated_at"]),
      )
    end
  end

  def me
    @me ||= @access_token.get('users/me.json').parsed do |me|
      Nerd.new(
        me["full_name"],
        me["hire_date"].blank? ? "" : Date.parse(me["hire_date"]),
        me["active"],
        Date.parse(nerd["updated_at"]),
      )
    end
  end

  private
  def all_nerds
    @access_token.get('users.json?include_inactive=true').parsed
  end

  def active_nerds
    @access_token.get('users.json').parsed
  end
end
