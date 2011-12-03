require 'nokogiri'
require 'image_spec'
require 'opengraph'

module Linkser
  module Objects
    class HTML < Linkser::Object

      def title
        ogp && ogp.title ||
          (e = nokogiri.css('title')).first && e.text
      end

      def description
        ogp && ogp.description ||
          (e = nokogiri.css('meta').find { |meta|
                 meta.get_attribute("name").eql? "description"
               }) && e.get_attribute("content")
      end

      def images
        Array.new.tap do |images|
          if ogp and ogp.image
            begin
              img_spec = ImageSpec.new(ogp.image)
              if valid_img? img_spec.width.to_f, img_spec.height.to_f
                images << Linkser::Resource.new({:type => "image", :url => ogp.image, :width => img_spec.width, :height => img_spec.height})
              end
            rescue
            end
          end        

          nokogiri.css('img').each do |img|
            break if images.length >= 5
            img_src = img.get_attribute("src")
            img_src = complete_url img_src, url
            img_uri = URI.parse(img_src)
            img_ext = File.extname(img_uri.path)
            img_name = File.basename(img_uri.path,img_ext)

            if [".jpg", ".jpeg", ".png"].include? img_ext
              begin
                img_spec = ImageSpec.new(img_src)
                if valid_img? img_spec.width.to_f, img_spec.height.to_f
                  images << Linkser::Resource.new({:type => "image", :url => img_src, :width => img_spec.width, :height => img_spec.height})
                end
              rescue
              end
            end
          end
        end      
      end

      def nokogiri
        Nokogiri::HTML(body)
      end

      def ogp
        ogp = OpenGraph::Object.new
        nokogiri.css('meta').each do |m|
          if m.attribute('property') && m.attribute('property').to_s.match(/^og:(.+)$/i)
            ogp[$1.gsub('-','_')] = m.attribute('content').to_s
          end
        end
        ogp = false if ogp.keys.empty? || !ogp.valid?
        ogp
      end
      
      def resource 
        Linkser::Resource.new ogp
      end

      memoize :nokogiri, :ogp,
              :title, :description, :images, :resource

      private

      def complete_url src, url
        uri = URI.parse(url)
        base_url = "http://" + uri.host + (uri.port!=80 ? ":" + uri.port.to_s : "")
        relative_url = "http://" + uri.host + (uri.port!=80 ? ":" + uri.port.to_s : "") + uri.path
        if src.index("http://")==0
          src
        elsif src.index("/")==0
          base_url + src
        else
          relative_url + src
        end
      end

      def valid_img? w, h
        if w > 199 or h > 199
          if ((w > 0 and h > 0 and ((w / h) < 3) and ((w / h) > 0.2)) or (w > 0 and h == 0 and w < 700) or (w == 0 and h > 0 and h < 700))
          return true
          end
        end
        false
      end
    end
  end
end
