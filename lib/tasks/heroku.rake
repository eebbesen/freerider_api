namespace :heroku do
  desc 'deploy local master, run migrations, restart and execute poll_and_persist_vehicles'
  task :deploy_and_run do
    system 'git push heroku master'
    Bundler.with_clean_env do
      system 'bundle install'
      system 'heroku run rake db:migrate'
      system 'heroku restart'
      system "heroku run rake poll_and_dropbox_vehicles['twincities']"
    end
  end
end
