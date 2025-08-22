require "rexml/document"
require "optparse"

### learning how native ruby works
module SvgTool

  class SvgDocumnet
    attr_reader :doc, :svg
    def self.from_file(path)
      xml = File.read(path, mode: "r:bom|utf-8")
      new(xml)
    end

    def initialize(xml_string)
      @doc = REXML::Document.new(xml_string)
      @svg = find_svg_root!(@doc)
    end

    def save(path)
      formatter = REXML::Formatters::Pretty.new
      formatter.compact = true
      File.open(path, "w:utf-8") { |f| formatter.write(@doc, f) }
    end

    private

    def find_svg_root!(document)
      svg = REXML::XPath.first(document, "/*[local-name()='svg']")
      raise "Не найден корневой элемент <svg>" unless svg
      svg
    end
  end

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
    
    def initialize(svg_doc, **opts)
      @svg_doc = svg_doc
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

      @svg_doc.svg.add_element(text_element)
      @svg_doc
    end

    private
    def format_float(value)
      value.to_f.round(4)
    end
  end

  class CLI
    def self.run(argv)
      options = {
        watermark: nil,
        out: nil,
        opacity: 0.15,
        size: 48
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Использование: ruby svg_tool.rb input.svg --watermark \"Your Name\" --out output.svg [--opacity 0.15] [--size 48]"
        opts.on("--watermark TEXT", "Текст водяного знака (обязательно)") { |v| options[:watermark] = v }
        opts.on("--out PATH", "Путь к выходному SVG (обязательно)") { |v| options[:out] = v }
        opts.on("--opacity N", Float, "Прозрачность 0..1 (по умолчанию 0.15)") { |v| options[:opacity] = v }
        opts.on("--size PX", Integer, "Размер шрифта (px), по умолчанию 48") { |v| options[:size] = v }
        opts.on("-h", "--help", "Показать помощь") { puts opts; exit }
      end
    

    begin
      parser.parse!(argv)
      input = argv.shift
      raise OptionParser::MissingArgument, "input.svg" unless input
      raise OptionParser::MissingArgument, "--watermark" unless options[:watermark]
      raise OptionParser::MissingArgument, "--out" unless options[:out]
    rescue OptionParser::ParseError => e
      warn "error: #{e.message}"
      warn parser
      exit 1
    end 
    svg_doc = SvgTool::SvgDocumnet.from_file(input)
    service = SvgTool::AddWatermarkService.new(
      svg_doc,
      text: options[:watermark],
      opacity: options[:opacity],
      font_size: options[:font_size]
    )
    service.call.save(options[:out])
    puts "ready: #{options[:out]}"

    rescue Errno::ENONET => e 
      warn "file not found 404 #{e.message}"
      exit 1
    rescue StandardError => e
      warn "cant read svg #{e.class}: #{e.message}"
      exit 1
    end
  end
  CLI.run(ARGV) if $PROGRAM_NAME == __FILE__
end