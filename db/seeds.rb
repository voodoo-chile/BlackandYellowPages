# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

User.create(:username => 'Admin', 
               :email => 'admin@blackandyellowpages.com', 
               :password => 'admin', 
               :password_confirmation => 'admin')

@user = User.first
@user.sponsor_id = 1
@user.active = true
@user.roles = ['agorist', 'admin']
@user.save

NewsItem.create(:title => "New Database",
                                   :body => "Your new database has been bootstrapped with an Admin user with the password \"admin\" (you're going to want to change that immediately).\r\n\r\nOnce you are logged in as Admin, you will be able to create a new \"Welcome to my new Web App\" news item, feature it, and then destroy this message. You must have at least one featured news item at all times.\r\n\r\nHave fun!",
                                   :featured => true, :user_id => 1)