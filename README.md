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
