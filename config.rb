require 'dotenv'

# use Rack::Rewrite do
#   rewrite %r{^\/page\/[0-9]}, '/index.html'
#   rewrite %r{^\/about}, '/index.html'
#   r301    %r{^\/submit},      'http://www.corsproxy.com/posttypes.tumblr.com/submit'
#   r301    %r{^\/ask},         'http://www.corsproxy.com/posttypes.tumblr.com/ask'
# end

before_configuration do
  Dotenv.load
end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

activate :livereload
activate :autoprefixer do |config|
  config.browsers = ['last 2 version', 'safari 5', 'ie 8', 'ie 9', 'opera 12.1', 'ios 6', 'android 4']
end

activate :tumblargh,
  api_key: ENV['TUMBLR_API_KEY'],
  blog: 'posttypes.tumblr.com'

after_configuration do
  @bower_config = JSON.parse(IO.read("#{root}/.bowerrc"))
  sprockets.append_path File.join "#{root}", @bower_config['directory']
end

activate :sync do |sync|
  sync.fog_provider = 'AWS'
  sync.fog_directory = ENV['AWS_BUCKET_NAME']
  sync.fog_region = 'us-east-1' # us-east-1, us-west-1, eu-west-1, ap-southeast-1
  sync.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
  sync.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  sync.existing_remote_files = 'keep'
  sync.gzip_compression = false
  sync.after_build = false
end

# Build-specific configuration
configure :build do
  # activate :asset_host
  # set :asset_host, "http://#{ENV['AWS_BUCKET_NAME']}.s3.amazonaws.com"

  ignore 'bower/**/*'
  ignore 'images/icons/*'
  ignore 'images/icons-2x/*'
  ignore 'stylesheets/app/**/*'
  ignore 'stylesheets/libs/**/*'
  ignore 'stylesheets/vendor/**/*'
  ignore 'javascripts/vendor/**/*'
  ignore 'javascripts/libs/**/*'
  ignore 'javascripts/app/**/*'

  activate :minify_css
  activate :minify_javascript
end
