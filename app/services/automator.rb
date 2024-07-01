# frozen_string_literal: true

require 'savon'
require 'woocommerce_api'
require 'down'

class Automator
  IMAGES_FILE_PATH = "#{Rails.root}/public/images/"
  PUBLIC_FILE_PATH = "http://142.44.163.51:3000/images/"
  MAX_FILE_SIZE = 3_145_728 # 3MB 
  
  def initialize
    @woo_consumer = WooConsumer.new
    @wsdl_consumer = WsdlConsumer.new(date: Time.current.beginning_of_week.strftime('%Y-%m-%d'))
  end

  def call
    product_list = @wsdl_consumer.call

    product_list.each do |product|
      product_data = sanitized_product_data(product) 

      woo_product_id =  @woo_consumer.get_product_id_by_sku_code(product_data[:sku])
      woo_product_id ?  @woo_consumer.update_product(woo_product_id, product_data) :  @woo_consumer.create_product(product_data)
      woo_product_id = nil
    end

     #batch_upsert method to make just one request to the WooCommerce API
     #@woo_consumer.batch_upsert(products_to_update, products_to_create)
  end

  private

  def sanitized_product_data(product)
    {
      name: product['nombre'],
      sku: product['codigo'],
      images: images_array_saving_locally(product),
      description: product['descripcion']
    }
  end

  def images_array_saving_locally(product)
    product['galeria'].map.with_index do |image, index|
      #code to save the image in the filesystem
      file_name = "#{product['codigo']}(#{index + 1}).jpg".gsub(/[^0-9A-Za-z.\\-]/, '_')
      file_path = IMAGES_FILE_PATH + file_name
      save_image(image, file_path)
      { src: PUBLIC_FILE_PATH + file_name}
    end
  end
  
  def save_image(image, file_path)
    Down.download(image['img'], destination: file_path, max_size: MAX_FILE_SIZE) unless File.exist?(file_path)
  end
end
