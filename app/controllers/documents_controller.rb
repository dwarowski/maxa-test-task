class DocumentsController < ApplicationController
  def create 
    svg_file = params[:file] ## Откуда взялся params 
    return render json: {error: "file not upload"}, status: :bad_request unless svg_file

    svg_content = svg_file.read

    service = AddWatermarkService.new(svg_content, text: "amerikaya hallo!")
    service.call

    out_path = Rails.root.join("public", "uploads", "watermarked.svg")
    service.save(out_path)

    render json: {url: "#{request.base_url}/upload/watermarked.svg"}
  end
end