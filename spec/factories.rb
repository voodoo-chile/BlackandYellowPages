Factory.define(:user) do |u|
  u.sequence(:username) {|n| "testuser#{n}"}
  u.sequence(:email) { |n| "testuser#{n}@blackandyellowpages.com" }
  u.password "password"
  u.password_confirmation "password"
end

Factory.define(:contact) do |c|
  c.association :user, :factory => :user
  c.skype "epoch.skype"
end

Factory.define(:trust_link) do |t|
  t.association :user, :factory => :user
end

Factory.define(:specialty) do |s|
  s.name "A Specialty"
end

Factory.define(:sponsor_key) do |i|
  i.association :sponsor, :factory => :user
end

Factory.define(:sponsorship_offer) do |s|
  s.association :user, :factory => :user
  s.association :potential_sponsor, :factory => :user
end