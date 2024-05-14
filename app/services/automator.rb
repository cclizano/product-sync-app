# frozen_string_literal: true

require 'savon'
require 'woocommerce_api'
require 'down'

class Automator
  IMAGES_FILE_PATH = "#{Rails.root}/app/assets/images/"
  MAX_FILE_SIZE = 3_145_728 # 3MB 
  
  def initialize
    @woo_consumer = WooConsumer.new
    @wsdl_consumer = WsdlConsumer.new(date: Time.current.beginning_of_week.strftime('%Y-%m-%d'))
  end

  def call
    product_list = wsdl_consumer.call
    products_to_update = []
    products_to_create = []

    product_list.find_each(batch_size: 100) do |product|
      product_data = sanitized_product_data(product) 

      woo_product_id = WooConsumer.new.get_product_id_by_sku_code(product_data['sku'])
      woo_product_id ? products_to_update << [woo_product_id, product_data] : products_to_create << product_data
    end

     #batch_upsert method to make just one request to the WooCommerce API
     woo_consumer.batch_upsert(products_to_update, products_to_create)

     #make a request to the WooCommerce API for each product
    # products_to_update.each do |product|
    #   woo_consumer.update_product(product[0], product[1])
    # end

    # products_to_create.each do |product|
    #   woo_consumer.create_product(product)
    # end
  end

  private

  def sanitized_product_data(product)
    {
      name: product['nombre'],
      sku: product['codigo'],
      sale_price: product['precio'],
      images: images_array_saving_locally(product),
      description: product['descripcion']
    }
  end

  def images_array_saving_locally(product)
    product['galeria'].map.with_index do |image, index|
      #code to save the image in the filesystem
      file_path = IMAGES_FILE_PATH + "#{product['codigo']}(#{index + 1}).jpg"
      save_image(image, file_path)
      { src: file_path }
    end
  end
  
  def save_image(image, file_path)
    Down.download(image['img'], destination: file_path, max_size: MAX_FILE_SIZE)
  end
end
