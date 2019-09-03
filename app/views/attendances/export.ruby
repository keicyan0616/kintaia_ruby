require 'csv'

CSV.generate do |csv|
  csv_column_names = %w(worked_on started_at finished_at)
  csv << csv_column_names
  @attendances.each do |attendance|
    column_values = [
      attendance.worked_on,
      attendance.started_at,
      attendance.finished_at
    ]
    csv << column_values
  end
end