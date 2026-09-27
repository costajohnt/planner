# frozen_string_literal: true

# Workshop descriptions are rendered with html_safe, which is only safe because
# they are sanitized on write. This backfill sanitizes descriptions written
# before that callback existed.
class SanitizeWorkshopDescriptions < ActiveRecord::Migration[8.1]
  def up
    Workshop.where.not(description: [nil, '']).find_each do |workshop|
      clean = Workshop.sanitized_description(workshop.description).to_s
      next if clean == workshop.description

      # update_columns avoids re-running the sanitize callback and re-running
      # validations; updated_at is set explicitly so the workshop's ETag and
      # fragment cache keys rotate for rows whose description changed.
      # rubocop:disable Rails/SkipsModelValidations
      workshop.update_columns(description: clean, updated_at: Time.current)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'The original unsanitized descriptions are gone.'
  end
end
