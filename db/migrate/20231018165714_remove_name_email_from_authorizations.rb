class RemoveNameEmailFromAuthorizations < ActiveRecord::Migration[7.0]
  def change
    remove_column :authorizations, :name, :string
    remove_column :authorizations, :email, :string
  end
end
