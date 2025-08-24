require "rails_helper"

# frozen_string_literal: true

describe "Documents_API", type: :request do
  describe "POST /documents" do
    # Files
    let(:svg_file) { fixture_file_upload(Rails.root.join("spec/fixture/files/test.svg"), "images/svg+xml")}
    let(:other_file) { fixture_file_upload(Rails.root.join("spec/fixture/files/text.txt"), "text/plain")}
    let(:incorrect_svg_file) { fixture_file_upload(Rails.root.join("spec/fixture/files/incorrect.svg"), "images/svg+xml") }
    
    # Check if controller works
    it "Returns link to converted file on success" do
      post "/documents",  params: { file: svg_file }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body) rescue nil

      expect(json).to include("url")
      expect(json["url"]).to match(/\.pdf$/)
    end

    # Check if file uploaded 
    it "Return error if file not uploaded" do
      post "/documents",  params: { }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    # Check if file ext correct 
    it "Return error if file type incorrect" do
      post "/documents", params: { file: other_file }
      expect(response).to have_http_status(:unsupported_media_type)
    end

    # Check if file uploaded have correct data
    it "Return error if svg incorrect" do
      post "/documents", params: { file: incorrect_svg_file }
      expect(response).to have_http_status(:bad_request)
    end

  end
end
