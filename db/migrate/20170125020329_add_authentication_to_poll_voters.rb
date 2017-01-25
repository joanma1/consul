class AddAuthenticationToPollVoters < ActiveRecord::Migration
  def change
    add_column :poll_voters, :encrypted_password, :string
  end
end
