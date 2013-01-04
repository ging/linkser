require 'nokogiri'
require 'image_spec'
require 'opengraph'

module Linkser
  module Objects
    class HTML < Linkser::Object

      def title
        @title ||= build_title
      end

      def description
        @description ||= build_description
      end

      def images
        @images ||= build_images
      end

      def nokogiri
        @nokogiri ||= Nokogiri::HTML(body)
      end

      def ogp
        @ogp ||= build_ogp
      end

      def resource
        @resource ||= build_resource
      end

      protected 

      def build_title
        ogp && ogp.title ||
          (e = nokogiri.css('title')).first && e.text
      end

      def build_description
        ogp && ogp.description ||
          (e = nokogiri.css('meta').find { |meta|
                 meta.get_attribute("name").eql? "description"
               }) && e.get_attribute("content")
      end

      def build_images
        max_images = @options[:max_images] || 5
        Array.new.tap do |images|
          if ogp and ogp.image
            begin
              img_spec = ImageSpec.new(ogp.image)
              if valid_img?(img_spec.width.to_f, img_spec.height.to_f) and can_hotlink_img?(ogp.image)
                images << Linkser::Resource.new({:type => "image", :url => ogp.image, :width => img_spec.width, :height => img_spec.height})
              end
            rescue
            end
          end        

          nokogiri.css('img').each do |img|
            break if images.length >= max_images
            img_src = img.get_attribute("src")
            next unless img_src
            img_src.strip!
            img_src = complete_url img_src, last_url
            img_uri = URI.parse(img_src)
            img_ext = File.extname(img_uri.path)
            img_name = File.basename(img_uri.path,img_ext)

            if [".jpg", ".jpeg", ".png"].include? img_ext
              begin
                img_spec = ImageSpec.new(img_src)
                if valid_img?(img_spec.width.to_f, img_spec.height.to_f) and can_hotlink_img?(img_src)
                  images << Linkser::Resource.new({:type => "image", :url => img_src, :width => img_spec.width, :height => img_spec.height})
                end
              rescue
              end
            end
          end
        end      
      end

      def build_ogp
        ogp = OpenGraph::Object.new
        nokogiri.css('meta').each do |m|
          if m.attribute('property') && m.attribute('property').to_s.match(/^og:(.+)$/i)
            ogp[$1.gsub('-','_')] = m.attribute('content').to_s
          end
        end
        ogp = false if ogp.keys.empty? || !ogp.valid?
        ogp
      end

      def build_resource 
        Linkser::Resource.new ogp if ogp
      end

      private

      def complete_url src, url
        uri = URI.parse(url)
        scheme = "#{uri.scheme}://"
        base_url = scheme + uri.host + (uri.port!=80 ? ":" + uri.port.to_s : "")
        relative_url = scheme + uri.host + (uri.port!=80 ? ":" + uri.port.to_s : "") + uri.path
        if src.index(scheme)==0
          src
        elsif src.index("/")==0
          base_url + src
        else
          URI.join(relative_url, src).to_s
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

      def can_hotlink_img? url, limit=10
	return false if limit < 0
        uri = URI.parse(url)
        http = Net::HTTP.new uri.host, uri.port
        http.start do |agent|
            response = agent.head uri.request_uri, { 'Referrer' => 'http://www.linkser.com/' }
            case response
            when Net::HTTPSuccess then
                return true
            when Net::HTTPRedirection then
                location = response['location']
                warn "Redirecting image to #{location}"
                return can_hotlink_img? location, limit - 1
            else
                return false
            end
        end
      end
    end
  end
end
