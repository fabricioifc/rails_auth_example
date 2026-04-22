class User < ApplicationRecord
	PROVIDER_UID_COLUMNS = {
		"github" => "github_uid",
		"twitter2" => "twitter_uid"
	}.freeze

	validates :email, uniqueness: { case_sensitive: false }, allow_nil: true

	def self.provider_uid_column(provider)
		PROVIDER_UID_COLUMNS[provider.to_s]
	end

	def linked_providers
		PROVIDER_UID_COLUMNS.each_with_object([]) do |(provider, column), providers|
			providers << provider if self[column].present?
		end
	end
end
