class AddProviderUidsToUsers < ActiveRecord::Migration[8.1]
  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  def up
    add_column :users, :github_uid, :string
    add_column :users, :twitter_uid, :string

    add_index :users, :github_uid, unique: true
    add_index :users, :twitter_uid, unique: true

    MigrationUser.reset_column_information

    MigrationUser.find_each do |user|
      case user.provider
      when "github"
        user.update_columns(github_uid: user.uid)
      when "twitter2"
        user.update_columns(twitter_uid: user.uid)
      end
    end
  end

  def down
    remove_index :users, :github_uid
    remove_index :users, :twitter_uid

    remove_column :users, :github_uid
    remove_column :users, :twitter_uid
  end
end
