class AddUserIdToVoters < ActiveRecord::Migration
  def change
    add_column :poll_voters, :user_id, :integer
  end
end
