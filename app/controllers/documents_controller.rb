class DocumentsController < ApplicationController
  def create 
    upload_dir = Rails.root.join("public", "uploads")
    download_dir = Rails.root.join("public", "downloads")
    FileUtils.mkdir_p([upload_dir, download_dir])


    svg_file = params[:file] ## Откуда взялся params 
    return render json: {error: "file not upload"}, status: :bad_request unless svg_file

    svg_content = svg_file.read
    filename = File.basename(svg_file.original_filename, ".*")
    filepath = upload_dir.join(filename.to_s)

    File.open(filepath, "wb") { |f| f.write(svg_content) }

    service = AddWatermarkService.new(svg_content, text: "amerikaya hallo!")
    service.call

    service.save(download_dir.join("#{filename}_marked.svg"))

    render json: {url: "#{request.base_url}/download/#{filename}_marked.svg"}
  end
end