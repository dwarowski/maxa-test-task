require "rexml/document"

###depricated
class AddWatermarkService
  DEFAULTS = {
    text: "watermark",
    opacity: 0.15,
    font_size: 48,
    fill: "#000",
    x: "80%",
    y: "80%",
    anchor: "middle",
    baseline: "middle"
  }.freeze()
  
  def initialize(svg_content, opts = {})
    @svg_doc = REXML::Document.new(svg_content)
    @opts = DEFAULTS.merge(opts.transform_keys(&:to_sym))
  end

  def call
    text_element = REXML::Element.new("text")
    text_element.text = @opts[:text]

    text_element.add_attribute("x", @opts[:x])
    text_element.add_attribute("y", @opts[:y])
    text_element.add_attribute("text-anchor", @opts[:anchor])
    text_element.add_attribute("dominant-baseline", @opts[:baseline])
    text_element.add_attribute("fill", @opts[:fill])
    text_element.add_attribute("fill-opacity", format_float(@opts[:opacity]))
    text_element.add_attribute("font-size", @opts[:font_size].to_s)
    text_element.add_attribute("font-family", "sans-serif")
    text_element.add_attribute("style", "pointer-events:none; user-select:none;")

    @svg_doc.root.add_element(text_element)
    self
  end

  def to_svg
    out = ""
    REXML::Formatters::Pretty.new.write(@svg_doc, out)
    out
  end

  def save(path)
    File.open(path, "w") { |f| f.write(to_svg)}
    path
  end
  
  private
  
  def format_float(value)
    value.to_f.round(4)
  end
end
