# typed: false
# frozen_string_literal: true
require 'json'

# TODO: use a real storage mechanism
EXAMPLE_DB = {
  'alice' => { id: 'alice' }
}

# TODO: use a real session mechanism
EXAMPLE_SESSION = {
  current_user_id: nil
}

class Server < Sinatra::Base

  # TODO: use real helpers
  helpers do
    def authenticated?; !!EXAMPLE_SESSION[:current_user_id]; end
    def current_user; EXAMPLE_DB.fetch(EXAMPLE_SESSION[:current_user_id], nil); end
    def set_current_user(user_id); EXAMPLE_SESSION[:current_user_id] = user_id; end
    def db_upsert_user(user_id); EXAMPLE_DB[user_id] ||= { id: user_id }; end
    def db_store_identity(user_id, identity); EXAMPLE_DB[user_id][:identity] = identity; end
    def db_load_identity(user_id); EXAMPLE_DB[user_id]&.fetch(:identity, nil); end
  end

  # TODO: ensure config is stored in a secure place
  configure do
    set config: JSON.parse(File.read('config-app.json'))
  end

  # TODO: use real auth mechanism
  get '/authenticate/:user_id' do
    db_upsert_user(params[:user_id])
    set_current_user(params[:user_id])
    200
  end

  # ---------------------------------------------------------------------------
  # Tanker identity example routes
  # ---------------------------------------------------------------------------

  get '/me/tanker_secret_identity' do
    halt 401, 'Unauthorized' unless authenticated?

    # add proper Content-Type header in the response
    content_type 'text/plain'

    # retrieve the identity of the current user if exist
    user_id = current_user[:id]
    identity = db_load_identity(user_id)

    unless identity
      app_id = settings.config['appId'];
      app_secret = settings.config['appSecret'];
      identity = Tanker::Identity.create_identity(app_id, app_secret, user_id)
      db_store_identity(user_id, identity)
    end

    identity
  end

  get '/users/:user_id/tanker_public_identity' do
    halt 401, 'Unauthorized' unless authenticated?

    # add proper Content-Type header in the response
    content_type 'text/plain'

    # retrieve the identity of the current user if exist
    identity = db_load_identity(params[:user_id])

    halt 404, 'User does not exist or does not have an identity (yet)' unless identity

    Tanker::Identity.get_public_identity(identity)
  end

  # ---------------------------------------------------------------------------
  # CORS
  # ---------------------------------------------------------------------------

  # All the code in this section is not required if your front-end application
  # and your user identity server share the same domain.
  configure do
    enable :cross_origin
  end

  # Activate CORS on all requests
  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  # Preflight request
  options "*" do
    response.headers["Allow"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end
end
