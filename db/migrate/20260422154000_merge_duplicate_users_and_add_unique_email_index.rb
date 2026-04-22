class MergeDuplicateUsersAndAddUniqueEmailIndex < ActiveRecord::Migration[8.1]
  class MigrationUser < ApplicationRecord
    self.table_name = "users"
  end

  def up
    MigrationUser.reset_column_information

    duplicate_email_keys.each do |email_key|
      users = MigrationUser.where("LOWER(email) = ?", email_key).order(:id).to_a
      primary_user = users.shift

      users.each do |duplicate_user|
        primary_user.update_columns(
          github_uid: primary_user.github_uid.presence || duplicate_user.github_uid,
          twitter_uid: primary_user.twitter_uid.presence || duplicate_user.twitter_uid,
          name: primary_user.name.presence || duplicate_user.name,
          provider: primary_user.provider.presence || duplicate_user.provider,
          uid: primary_user.uid.presence || duplicate_user.uid,
          updated_at: Time.current
        )

        duplicate_user.destroy!
      end
    end

    add_index :users, "LOWER(email)", unique: true, name: "index_users_on_lower_email"
  end

  def down
    remove_index :users, name: "index_users_on_lower_email"
  end

  private

  def duplicate_email_keys
    MigrationUser
      .where.not(email: [nil, ""])
      .group("LOWER(email)")
      .having("COUNT(*) > 1")
      .pluck(Arel.sql("LOWER(email)"))
  end
end
