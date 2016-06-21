class CreatePrs < ActiveRecord::Migration
  def change
    create_table :prs do |t|
      t.integer :pr_id
      t.string :owner_repo_name
      t.string :repo_name
      t.string :base_ssh_url
      t.string :base_branch
      t.string :sha
      t.string :ssh_url
      t.string :branch
      t.text :details

      t.timestamps null: false
    end
    add_index :prs, :pr_id, unique: true
  end
end
