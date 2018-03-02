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
