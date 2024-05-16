use Rack::Static,
  :urls => ["/images", "/js", "/css"],
  :root => "public"

run lambda { |env|
  [
    200,
    {
      'Content-Type'  => 'text/html',
      'Cache-Control' => 'public, max-age=86400'
    },
    File.open('public/422.html', File::RDONLY)
  ]
}

require_relative "config/environment"

run Rails.application
Rails.application.load_server
