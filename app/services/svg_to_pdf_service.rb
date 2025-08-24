require "prawn"
require "prawn-svg"

# Convretion Service
#
# Converts an SVG file to PDF, adding watermark and margin.
#
# @param svg_content [String] SVG file content
# @param options [Hash] Optional params hash
# @option options [String] :watermark (DEFAULTS[:watermark]) Watermark to display
# @option options [Integer] :margin_cm (DEFAULTS[:margin_cm]) Margin for borders
class SvgToPdfService
  attr_reader :svg_content, :options

  DEFAULTS = {
    watermark: "Dima-MAXA-test-task",
    margin_cm: 1
  }.freeze


  def initialize(svg_content, options = {})
    @svg_content = svg_content
    @options = DEFAULTS.merge(options)
  end

  # Creates new pdf add watermark, borders and svg 
  def call
    # Borders
    pdf = Prawn::Document.new(
      margin: @options[:margin_cm] * 28.35
    )

    # Bounds
    max_width = pdf.bounds.width
    max_height = pdf.bounds.height

    # Svg
    svg_handler = Prawn::Svg::Interface.new(
      @svg_content,
      pdf,
      at: [pdf.bounds.left, pdf.bounds.top],
      width: max_width,
      height: max_height,
    )
    svg_handler.draw

    # Watermark
    pdf.transparent(0.1) do
      pdf.draw_text(
        @options[:watermark],
        at: [pdf.bounds.width/4 , pdf.bounds.height/2],
        size: 50,
        rotate: 30
      )
    end
    pdf
  end

  # Saves changed file to path
  #
  # @param [String] path Full path and filename to save pdf
  # @return [String] file content string  
  def save(path)
    # save pdf to determined path
    call.render_file(path)
  end
end