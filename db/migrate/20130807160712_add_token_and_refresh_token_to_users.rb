class AddTokenAndRefreshTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :token, :string
    add_column :users, :refresh_token, :string
  end
end
