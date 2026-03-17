# Monkey-patch for activerecord-nulldb-adapter compatibility with Rails 8.1
# Rails 8.1 introduced a new method check_current_protected_environment! that
# the nulldb adapter doesn't implement yet
if defined?(ActiveRecord::Tasks::NullDBDatabaseTasks)
  module ActiveRecord
    module Tasks
      class NullDBDatabaseTasks
        # Rails 8.1 requires this method for database tasks
        # Since nulldb is a test adapter with no actual database, we can safely no-op
        def check_current_protected_environment!(db_config, migration_class)
          # No-op: nulldb has no actual database to protect
        end
      end
    end

    # Disable migration checks for nulldb in test environment
    # nulldb doesn't have actual migrations since there's no real database
    if Rails.env.test?
      class Migration
        class << self
          def check_pending!(connection = nil)
            # No-op for nulldb adapter
          end
        end
      end
    end
  end
end
