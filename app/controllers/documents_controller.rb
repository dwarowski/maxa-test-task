class DocumentsController < ApplicationController
  def create 
    svg_file = params[:file] ## Откуда взялся params 
    unless svg_file
      render json: {error: "file not upload"}, status: :bad_request # Кострукция непонтная 
      return 
    end

    tmp_path = Rails.root.join("tmp", svg_file.original_filename)
    File.binwrite(tmp_path, svg_file.read)

    service = AddWatermarkService.new(tmp_path, text: "amerikaya hallo!")
    svg_doc = service.call
    out_path = tmp_path.sub_ext(".svg")
    svg_doc.save(out_path)

    render json: {url: "/download/#{out_path.basename}"}
  end
end