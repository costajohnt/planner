# frozen_string_literal: true

# Workshop descriptions are rendered with html_safe, which is only safe because
# they are sanitized on write. This backfill sanitizes descriptions written
# before that callback existed.
class SanitizeWorkshopDescriptions < ActiveRecord::Migration[8.1]
  def up
    Workshop.where.not(description: [nil, '']).find_each do |workshop|
      clean = ActionController::Base.helpers.sanitize(workshop.description)
      # update_columns avoids re-running the sanitize callback and touching
      # updated_at for every workshop; validations cannot add value here.
      # rubocop:disable Rails/SkipsModelValidations
      workshop.update_columns(description: clean.to_s) unless clean.to_s == workshop.description
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'The original unsanitized descriptions are gone.'
  end
end
