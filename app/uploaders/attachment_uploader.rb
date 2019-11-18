# encoding: utf-8
require 'mime/types'

class AttachmentUploader < BaseUploader

  # storage :qiniu
  
  def filename
    if super.present?
      "#{secure_token}.#{file.extension}"
    end
  end
  
  process :extract_content_type
  
  def extract_content_type
    if file.content_type == 'application/octet-stream' || file.content_type.blank?
      content_type = MIME::Types.type_for(original_filename).first
    else
      content_type = file.content_type
    end

    model.data_content_type = content_type.to_s
    model.old_filename = original_filename
  end
  
  process :set_size
  def set_size
    model.data_file_size = file.size
  end
  
  process :read_dimensions
  def read_dimensions
    if file && model && is_image?
      model.width, model.height = ::MiniMagick::Image.open(file.file)[:dimensions]
    end
  end
  
  process :strip
  # Strips out all embedded information from the image
  #
  #   process :strip
  #
  def strip
    if is_image?
      manipulate! do |img|
        img.strip
        img = yield(img) if block_given?
        img
      end
    end
  end
  
  def is_image?
    ['image/jpeg', 'image/png', 'image/gif', 'image/jpg', 'image/pjpeg', 'image/tiff', 'image/x-png'].include?(model.data_content_type)
  end

  process :quality => 80
  # Reduces the quality of the image to the percentage given
  #
  #   process :quality => 90
  #
  def quality(percentage)
    if is_image?
      manipulate! do |img|
        if img["%Q"].to_i != percentage
          img.quality(percentage.to_s)
        end
        img = yield(img) if block_given?
        img
      end
    end
  end
  
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  def extension_whitelist
    %w(jpg jpeg png tiff webp gif mp4 mov pdf doc docx xls xlsx ppt pptx rtf txt zip rar 7z ogg wav mp3)
  end
  
  protected
    def secure_token
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
    end

end
