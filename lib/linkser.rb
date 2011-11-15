require 'linkser/version'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'RMagick'
require 'image_spec'

module Linkser
  def self.parse url, options={}
    if is_valid_url? url
      if !is_accesible_url? url
      raise "Unreachable URL"
      end
    else
    raise "Invalid URL"
    end

    return parse_html url
  end

  private

  def self.is_accesible_url? url
    begin
      open(url)
      return true
    rescue
    return false
    end
  end

  def self.is_valid_url? url
    begin
      uri = URI.parse(url)
      if [:scheme, :host].any? { |i| uri.send(i).blank? }
      raise(URI::InvalidURIError)
      end
      return true
    rescue URI::InvalidURIError => e
    return false
    end
  end

  def self.get_complete_url src, url
    uri = URI.parse(url)
    base_url = "http://" + uri.host + (uri.port!=80 ? ":" + uri.port.to_s : "")
    relative_url = "http://" + uri.host + (uri.port!=80 ? ":" + uri.port.to_s : "") + uri.path
    if src.index("http://")==0
    src = src
    #stays the same
    elsif src.index("/")==0
    src = base_url + src
    else
    src = relative_url + src
    end
  end

  def self.parse_html url
    parsed_page = Hash.new

    doc = Nokogiri::HTML(open(url))

    doc.css('title').each do |title|
      parsed_page.update({:title => title.text})
    end

    doc.css('meta').each do |meta|
      if meta.get_attribute("name").eql? "description"
        parsed_page.update({:description => meta.get_attribute("content")})
      end
    end
    
    images = Array.new
    
    doc.css('img').each do |img|
      img_src = img.get_attribute("src")
      img_src = get_complete_url img_src, url
      img_uri = URI.parse(img_src)
      img_ext = File.extname(img_uri.path)
      img_name = File.basename(img_uri.path,img_ext)
      if [".jpg", ".jpeg", ".png"].include? img_ext
        begin
          img_spec = ImageSpec.new(img_src)
          w = img_spec.width.to_f
          h = img_spec.height.to_f
          if w > 199 or w > 199
            if ((w > 0 and h > 0 and ((w / h) < 3) and ((w / h) > 0.2)) or (w > 0 and h == 0 and w < 700) or (w == 0 and h > 0 and h < 700)) and img_name.index("logo").nil?
            image = {:img => img_src, :width => w.to_i, :height => h.to_i}
            images << image
            end
          end
        rescue
        end
      end
    end
    
    if images!=[]
        parsed_page.update({:images => images})      
    end

    return parsed_page
  end
end

