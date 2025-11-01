class DashboardController < ApplicationController
  before_action :authenticate_user!


  def index
    @jobs_by_status = current_user.jobs.group(:status).count
    @jobs_by_time = current_user.jobs
                               .group_by { |job| job.created_at.to_date }
                              .transform_values(&:count)

    @total_jobs = current_user.jobs.count
    @interview_jobs = current_user.jobs.where(status: "interview").count
    @pending_jobs = current_user.jobs.where(status: "pending").count
  end
end
