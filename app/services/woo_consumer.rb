# frozen_string_literal: true

require 'woocommerce_api'

class WooConsumer
  STORE_URL = 'https://puntook.com.uy'.freeze
  CONSUMER_KEY = 'ck_58ac83a19a6dc9f7c0a8671d7393cd2287e73ce4'.freeze
  CONSUMER_SECRET = 'cs_69cc42d893f9b6b3992a72c07be860c9b5f6cd41'.freeze
  VERSION = 'wc/v3'.freeze
 
  def get_product_id_by_sku_code(sku_code)
    product = client.get('products', {sku: sku_code})&.first
    
    product ? product['id'] : nil
  end

  def create_product(data)
    result = client.post('products', data)
  end

  def update_product(id, data)
    client.put("products/#{id}", data)
  end

  def batch_upsert(products_to_update, products_to_create)
    data = {
      create: products_to_create,
      update: products_to_update
    }
    client.post("products/batch", data)
  end

  def delete_product(id)
    client.delete("products/#{id}", force: true)
  end

  def products
    client.get('products')
  end

  private

  def client
    WooCommerce::API.new(STORE_URL, CONSUMER_KEY, CONSUMER_SECRET, options)                   
  end

  def options
    { wp_api: true, version: VERSION}
  end
end
