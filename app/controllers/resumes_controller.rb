class ResumesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_resume, only: [:show , :edit, :update, :destroy]
  before_action :autorize_user!,only: [:show , :edit, :update, :destroy]
  def new
    @resume = Resume.new
  end

  def create
    @resume = current_user.resumes.build(resume_params)

    if @resume.save
      extracted = extract_text(@resume.file)
      @resume.update(extracted_text: extracted)
      redirect_to @resume, notice: "Resume uploaded and text extracted!"
    else
      render :new
    end
  end

  def show
    @resume = Resume.find(params[:id])
  end

  private

  def resume_params
    params.require(:resume).permit(:file)
  end

  def extract_text(file)
    return unless file.attached?

    path = ActiveStorage::Blob.service.send(:path_for, file.key)
    ext = File.extname(file.filename.to_s).downcase

    case ext
    when ".pdf"
      reader = PDF::Reader.new(path)
      reader.pages.map(&:text).join("\n")
    when ".docx"
      doc = Docx::Document.open(path)
      doc.paragraphs.map(&:text).join("\n")
    else
      "Unsupported file type"
    end
  end
end
