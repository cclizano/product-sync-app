# frozen_string_literal: true

require 'savon'

class WsdlConsumer
  REQUEST_URL = 'http://www.cdrmedios.com/ws/productos/service.php?class=SublimewsProductosUsuariosCompleto&wsdl'.freeze
  ACTION = :productos_con_galeria
  
  def initialize(date:)
    @date = date 
  end
 
  def call
    result = result(response_body)

    JSON.parse(result)
  end

  def client
    Savon.client(wsdl: REQUEST_URL)
  end
  

  def request_body
    {
      email: 'javierduartepc@gmail.com',
      token: 'aeTWETae535g4.22',
      formato: 'json',
      fecha: @date
    }
  end

  def result(body)
    response(body, %i[productos_con_galeria_response productos_con_galeria_return])
  end

  def response_body
    client.call(ACTION, message: request_body).body
  end

  def response(body, keys)
    body.dig(*keys)
  end
end
