class ReportController < ApplicationController

  def download_all

    if Person.dump_all
      send_file(
          "#{Rails.root}/dump.csv",
          filename: "all_brk_records_#{Time.now.to_s(:db).gsub(/\s+/, '_')}.csv",
          type: "application/csv"
      ) and return
    end

    redirect_to "/"
  end
 end
