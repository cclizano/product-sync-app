# frozen_string_literal: true

namespace :automated_tasks do
  desc 'Calling automator service'
  task update_products: :environment do
    puts "Calling wsdl service at #{Time.now} with #{WsdlConsumer.new(date: Time.current.beginning_of_week.strftime('%Y-%m-%d')).call.size} products."
    Automator.new.call
  end
end