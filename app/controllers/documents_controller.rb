class DocumentsController < ApplicationController
  
  # Documents endpoint
  #
  # @return [json] 
  # On succsess {url: http://example.org/}
  # On failure {error: description, status: 400}
  def create 
    # Create basic folders
    upload_dir = Rails.root.join("public", "uploads")
    download_dir = Rails.root.join("public", "downloads")
    FileUtils.mkdir_p([upload_dir, download_dir])

    # Get file from multipart
    file = params[:file]
    return render json: DocumentBlueprint.render({error: "File not uploaded", url: nil}), status: :unprocessable_content unless file && file.respond_to?(:original_filename)

    # File essentials
    file_content = file.read
    if !file.original_filename.match(/\.svg/)
      return render json: DocumentBlueprint.render({ error: "Unsupported file format", url: nil}), status: :unsupported_media_type
    end 
    filename = File.basename(file.original_filename, ".*")
    filepath = upload_dir.join("#{filename}.svg")
    
    # Save uploaded file
    File.open(filepath, "wb") { |f| f.write(file_content) }

    # Convert and mark and check for correct SVG
    begin 
      service = SvgToPdfService.new(file_content, watermark: "MAXA-test-task")
      service.save(download_dir.join("#{filename}_marked.pdf"))
    rescue StandardError => e
      Rails.logger.error("SVG error: #{e.message}")
      return render json: DocumentBlueprint.render({ error: "Invalid SVG file", url: nil}), status: :bad_request
    end

    render json: DocumentBlueprint.render({error: nil, url: "#{request.base_url}/downloads/#{filename}_marked.pdf"}), status: :ok
  end
end