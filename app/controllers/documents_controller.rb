class DocumentsController < ApplicationController
  def create 
    #create folders
    upload_dir = Rails.root.join("public", "uploads")
    download_dir = Rails.root.join("public", "downloads")
    FileUtils.mkdir_p([upload_dir, download_dir])

    #get file
    file = params[:file]
    return render json: {error: "file not upload"}, status: :bad_request unless file && file.respond_to?(:original_filename)

    #file essentials
    file_content = file.read
    if !file.original_filename.match(/\.svg/)
      return render json: { error: "unsupported file format" }, status: :bad_request
    end 
    filename = File.basename(file.original_filename, ".*")
    filepath = upload_dir.join("#{filename}.svg")
    
    #save upload
    File.open(filepath, "wb") { |f| f.write(file_content) }

    #convert and mark
    begin 
      service = SvgToPdfService.new(file_content, watermark: "MAXA-test-task")
      service.save(download_dir.join("#{filename}_marked.pdf"))
    rescue StandardError => e
      Rails.logger.error("SVG error: #{e.message}")
      return render json: { error: "Invalid SVG file"}, status: :bad_request
    end

    #return
    render json: {url: "#{request.base_url}/downloads/#{filename}_marked.pdf"}
  end
end