# Creating a Nuxt/Rails-API skeleton app with authentication

## Kicking off

mkdir autheg
cd autheg
rails new autheg-backend -T --skip-spring -C -B -d postgresql --api
vue init nuxt-community/starter-template autheg-frontend
cd autheg-frontend
yarn generate-lock-entry > yarn.lock

Add "export UID=$(id -u)" to ~/.zshrc

Create docker-compose.yml, the two Dockerfiles and the two .dockerignore files + add vendor/bundle to the .gitignore
[Explain these]

docker-compose build
docker-compose run -u root backend bundle
docker-compose run frontend yarn

Edit database.yml (add host and username)
Edit package.json (add HOST=0.0.0.0)

docker-compose run backend rails db:create
docker-compose up

Check you can access the two environments at http://localhost:8080 and http://localhost:3000

Woop! Time to commit to version control!

## Getting the two talking to each other

### Add an example API method

docker-compose run backend bash
> rails g resource example name:string colour:string
> rails db:migrate
> rails c
> > {"foo" => "green", "bar" => "red", "baz" => "purple"}.each {|n,c| Example.create!(name: n, colour: c)}

Move the route into api/json scope in routes.rb

Add an index method to ExamplesController:

```ruby
def index
  examples = Example.all.select(:id, :name, :colour)
  render json: examples
end
```

Visit http://localhost:8080/api/examples to check it's working.

### Add a frontend view for that method

docker-compose run frontend yarn add @nuxtjs/axios

Add some config to nuxt.config.js:

```javascript
modules: [
  '@nuxtjs/axios'
],
axios: {
  host: 'localhost',
  port: 8080,
  prefix: '/api'
},
```

Replace index.vue with the version from this git checkin.

http://localhost:3000 will give a CORS error.

Add 'rack-cors' to Gemfile and
docker-compose run -u root backend bundle

Uncomment cors.rb and change example.com to localhost:3000

Restart docker-compose

Visit http://localhost:3000 to see your example rendered. Try adding a row in the DB and see it reflected in the frontend.

Time to commit to version control!

## Add user authentication with devise-jwt

### Installation

Add 'devise' and 'devise-jwt' to Gemfile and
docker-compose run -u root backend bundle

docker-compose run backend bash
> rails g devise:install
> rails g devise user

Install devise-jwt:

Add secrets to secrets.yml (jwt_secret, exactly like secret_key_base).

Add this to devise.rb:

```ruby
config.jwt do |jwt|
  jwt.secret = Rails.application.secrets.jwt_secret
end
```

Create a blacklist for logging out:

> rails g model jwt_blacklist jti:string:index exp:datetime

(be sure to add null: false to each column in the generated migration, and delete the timestamps)

in jwt_blacklist.rb:

```ruby
include Devise::JWT::RevocationStrategies::Blacklist
```

in user.rb:

```ruby
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :trackable, :validatable,
       :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist
```

> rails db:migrate

In routes.rb, move the 'devise_for' into our api scope.

OK. Let's create a user and then try logging them in:

> rails c
>> User.create!(email: 'test@example.com', password: 'password')

Restart docker-compose.

Try POSTing to http://localhost:8080/api/users/sign_in with:

```json
{"user": {"email": "test@example.com", "password": "password"}}
```

you should get back a response with an Authorization header containing a signed JWT.

That JWT header would be enough to sign users in on some frontends, but @nuxtjs/auth needs the token to be in the body of the response, and it also needs a method for reading the logged-in user data from the server.

First, be sure to uncomment jbuilder and
docker-compose run -u root backend bundle

Let's override the SessionsController:

> rails g controller sessions

```ruby
class SessionsController < Devise::SessionsController
  def create
    super { @token = current_token }
  end

  def show
  end

  private

  def current_token
    request.env['warden-jwt_auth.token']
  end
end
```

app/views/devise/sessions/create.json.jbuilder:
```ruby
json.token @token
```

app/views/devise/sessions/show.json.jbuilder:
```ruby
if user_signed_in?
  json.user do
    json.(current_user, :id, :email)
  end
end
```

and in routes.rb:

```ruby
devise_for :users, controllers: {sessions: 'sessions'}
devise_scope :user do
  get 'users/current', to: 'sessions#show'
end
```

Restart docker-compose and then try these methods out. Do the earlier POST and this time the token should come back in the response.

Now you should be able to make a GET request to http://localhost:8080/api/users/current with that token in the headers (Authorization: Bearer <token>) and get back your user's email address.

Finally, you should be able to send a DELETE request to http://localhost:8080/api/users/sign_out with that header to blacklist the token. After which you will not be able to use it for the GET request any more (it will return an empty object).

Last thing - let's make the /examples method fail for unauthorized users. Add this to the ExamplesController:

```ruby
before_action :authenticate_user!
```

Now you should only be able to call that API method if you attach a valid JWT header.

All working? Time to save to version control!

### Hooking up the frontend

Visiting your frontend now will result in an error (red flash) because the API method requires authentication.

Install the @nuxtjs/auth library:

> cd autheg-frontend
> yarn add @nuxtjs/auth

Add '@nuxjs/auth' to modules and a config section, such as:

```javascript
auth: {
  endpoints: {
    login:  { url: '/users/sign_in' },
    logout: { url: '/users/sign_out', method: 'delete' },
    user:   { url: '/users/current' }
  }
}
```

Enable the Vuex store to store the auth state (store/index.js):

```javascript
export default {
  state: () => ({
  })
}
```

and restart docker-compose.

Now create a pages/login.vue which uses the objects provided by this library.

Finally, you'll want to redirect users who are not signed in and visit the homepage.

Add to index.vue:

```javascript
middleware: ['auth'],
```

And that's it! Check out the [auth documentation](https://auth.nuxtjs.org/) and [demo apps](https://github.com/nuxt-community/auth-module/tree/dev/examples) for more examples and config.
