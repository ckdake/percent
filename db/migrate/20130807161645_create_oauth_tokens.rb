class CreateOauthTokens < ActiveRecord::Migration
  def change
    create_table :oauth_tokens do |t|
      t.string :token, default: "", null: false
      t.string :refresh_token, default: "", null: false
      t.datetime :expires_at
      t.integer :user_id

      t.timestamps
    end
  end
end
