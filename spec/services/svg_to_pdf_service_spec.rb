require "rails_helper"

# frozen_string_literal: true

describe SvgToPdfService do
  let(:svg) {"<svg xmlns='http://www.w3.org/2000/svg'><rect width='100' height='100'/></svg>"}
  it "Convert to pdf and add watermark" do
    service = described_class.new(svg, watermark: "test")
    out_path = Rails.root.join("tmp", "test.pdf")
    service.save(out_path)

    expect(File.exist?(out_path)).to be true
    expect(File.size(out_path)).to be > 0
  end
end
