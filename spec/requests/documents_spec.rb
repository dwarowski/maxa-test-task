require "rails_helper"

# frozen_string_literal: true

describe "Documents_API", type: :request do
  describe "POST /documents" do
    let(:svg_file) { fixture_file_upload(Rails.root.join("spec/fixture/files/test.svg"), "images/svg+xml")}
    let(:other_file) { fixture_file_upload(Rails.root.join("spec/fixture/files/text.txt"), "text/plain")}
    let(:incorrect_svg_file) { fixture_file_upload(Rails.root.join("spec/fixture/files/incorrect.svg"), "images/svg+xml") }
    
    it "Returns link to converted file on success" do
      post "/documents",  params: { file: svg_file }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body) rescue nil

      expect(json).to include("url")
      expect(json["url"]).to match(/\.pdf$/)
    end

  
    it "Return error if file not uploaded" do
      post "/documents",  params: { }
      expect(response).to have_http_status(:bad_request)
    end

    it "Return error if file type incorrect" do
      post "/documents", params: { file: other_file }
      expect(response).to have_http_status(:bad_request)
    end

    it "Return error if svg incorrect" do
      post "/documents", params: { file: incorrect_svg_file }
      expect(response).to have_http_status(:bad_request)
    end

  end
end
