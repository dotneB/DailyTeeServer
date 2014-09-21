namespace :db do

  desc 'Fix for automatic pk sequence getting out of step with your data rows.'
  task reset_pk: :environment do
    ActiveRecord::Base.connection
                      .tables
                      .reject { |t| t == 'schema_migrations' }
                      .each do |table|
      ActiveRecord::Base.connection.reset_pk_sequence!(table)
    end
  end

end