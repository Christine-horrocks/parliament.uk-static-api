require 'sinatra'
require 'sinatra/namespace'

module Parliament
  class APIv1 < Sinatra::Base
    ID_REGEX = /\w{8}/

    register Sinatra::Namespace

    configure do
      enable :logging
      enable :raise_errors if ENV['AIRBRAKE_API_KEY'] && ENV['AIRBRAKE_PROJECT_ID']
    end

    set :public_folder, Proc.new { File.join(root, 'data') }

    get '/' do
      'Welcome to the static Parliament API'
    end

    namespace '/*' do
      get do
        respond(request.path_info)
      end
    end

    private

    def respond(path)
      file_path = File.join(settings.public_folder, 'api', 'v1', path)

      file_exists = File.file?(file_path)

      if file_exists
        ntriple_response(file_path)
      else
        index_file_path = File.join(file_path, 'index')

        File.file?(index_file_path) ? ntriple_response(index_file_path) : not_found
      end
    end

    def ntriple_response(path)
      puts "SERVING FILE: #{path}"
      send_file(path, type: 'application/n-triples', disposition: 'inline')
    end

    def id_param(param)
      return not_found unless param.match? ID_REGEX

      param
    end
  end
end
