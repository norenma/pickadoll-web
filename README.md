Pickadoll web app
-----------------

How to get it up and running locally:

1. Clone this repository.
2. Set up MySQL with a database for the app.
3. Set up a `config/database.yml` file from `config/database.yml.template`.
4. From the command line, navigate to the project directory and run `bundle install` to install all the necessary gems.
5. Also from the project directory, run `bin/rails server` to start the server.
6. Browse to `localhost:3000` and log in using `admin` / `password`.

How to deploy:

1. *(if necessary)* On the server, set up a user with sudo privileges.
2. *(if necessary)* Make sure the operating system is up to date.
3. *(if necessary)* Install nginx, MySQL (or MariaDB), rbenv and Ruby (with Rails and Bundler).
4. *(if necessary)* Set up a database for the app.
5. *(if necessary)* Set up SSH keys so that the repository can be accessed.
6. *(if necessary)* Run `bundle exec cap production setup`.
7. Run `bundle exec cap production deploy`.
