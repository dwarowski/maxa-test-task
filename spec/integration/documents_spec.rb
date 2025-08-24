require "swagger_helper"

# frozen_string_literal: true

describe "Documents API", type: :request do
  path "/documents" do
    post "SVG Upload" do
      description "Upload SVG file and convert it to PDF with watermark"
      tags "Convertion"
      consumes "multipart/form-data"
      produces "application/json"

      parameter name: :file,
        in: :formData,
        type: :file,
        description: "File to convert",
        required: true

      
      response "200", "Converted file URL" do
        let(:file) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixture/files/test.svg"), "image/svg+xml") }
        
        schema type: :object, 
          properties: { url: { type: :string, format: :uri } }, 
          required: ["url"], 
          example: { url: "http://localhost:3000/documents/file.pdf" }

        run_test! do |response|
          json = JSON.parse(response.body)
          expect(json).to include("url")
          expect(json["url"]).to match(/\.pdf$/)
        end
      end

      response "204", "File not uploaded" do
        let(:file) { nil }

        schema type: :object, 
        properties: { error: { type: :string } }, 
        required: ["error"], 
        example: { error: "File not uploaded" }

        run_test!
      end

      response "415", "Unsupported file format" do
        let(:file) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixture/files/text.txt"), "text/plain") }
        
        schema type: :object, 
        properties: { error: { type: :string } }, 
        required: ["error"], 
        example: { error: "Unsupported file format" }

        run_test!
      end

      response "400", "Invalid SVG file" do
        let(:file) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixture/files/incorrect.svg"), "image/svg+xml") }
        
        schema type: :object, 
        properties: { error: { type: :string } }, 
        required: ["error"], 
        example: { error: "Invalid SVG file" }

        run_test!
      end
    end
  end
end
