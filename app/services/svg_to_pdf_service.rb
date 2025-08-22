require "prawn"
require "prawn-svg"

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

  def call
    #borders
    pdf = Prawn::Document.new(
      margin: @options[:margin_cm] * 28.35
    )

    #bounds
    max_width = pdf.bounds.width
    max_height = pdf.bounds.height

    #svg
    svg_handler = Prawn::Svg::Interface.new(
      @svg_content,
      pdf,
      at: [pdf.bounds.left, pdf.bounds.top],
      width: max_width,
      height: max_height,
    )
    svg_handler.draw

    #watermark
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

  def save(path)
    call.render_file(path)
  end
end