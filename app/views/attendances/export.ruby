require 'csv'

CSV.generate do |csv|
  csv_column_names = %w(worked_on started_at finished_at)
  csv << csv_column_names
  @attendances.each do |attendance|
    @started = ""
    @finished = ""
    @started = attendance.started_at.strftime("%H:%M") if attendance.started_at.present?
    @finished = attendance.finished_at.strftime("%H:%M") if attendance.finished_at.present?
    column_values = [
      attendance.worked_on,
      @started,
      @finished
    ]
    csv << column_values
  end
end