require 'spec_helper'

describe 'User' do
  before do
    @user = User.create(username: "jojo dodo", email: "lovewins@gmail.com", password: "testing")
  end

  it 'can slug the username' do
    expect(@user.slug).to eq("jojo-dodo")
  end

  it 'can find a user based on the slug' do
    slug = @user.slug
    expect(User.find_by_slug(slug).username).to eq("jojo dodo")
  end

  it 'has a secure password' do
    expect(@user.authenticate("Dododo")).to eq(false)
    expect(@user.authenticate("testing")).to eq(@user)
  end
end
