class JobsController < ApplicationController

before_action :authenticate_user!
before_action :set_job, only: [:show, :edit, :update, :destroy]

  def index
    @jobs = current_user.jobs.order(created_at: :desc)
  end

  def show
  end

  def new
    @job = current_user.jobs.build
  end

  def create
    @job = current_user.jobs.build(job_params)
    if @job.save   
      redirect_to jobs_path, notice: "Job was successfully created."
    else
      render :new, alert: "There was an error creating the job."
    end
  end

  def edit
  end

  def update
    if @job.update(job_params)
      redirect_to jobs_path, notice: "Job update succesfully"
    else
      render :edit, alert: "failed to update job"
    end
  end

  def destroy
    @job.destroy
    redirect_to jobs_path, notice: "Job was successfully deleted"
  end

  private

  def set_job
    @job = current_user.jobs.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:title, :company, :location, :description, :status, :applied_on)
  end
end

