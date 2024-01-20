# frozen_string_literal: true

class UpdateSchemaForCustomToken < ActiveRecord::Migration[7.0]
  def change
    remove_column :authorizations, :access_token, :string
    remove_column :authorizations, :refresh_token, :string

    add_column :users, :custom_token, :string

    add_index :users, :custom_token, unique: true
  end
end
