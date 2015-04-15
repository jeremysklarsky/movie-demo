require 'rails_helper'

RSpec.feature "UserLogins", type: :feature do
  
  describe '#signing up' do  
    scenario 'user can sign up' do 
      visit root_path
      click_link("Sign up") 
      fill_in("Name", :with => "Amy Poehler")
      fill_in("Email", :with => "amy@gmail.com")
      fill_in("Password", :with => "foobar")
      fill_in("Password confirmation", :with => "foobar")
      click_button "Sign Up"
      expect(User.find_by(:email => "amy@gmail.com" ).name).to eq("Amy Poehler")
    end

    scenario 'user is redirected to user show page after signing up' do 
      visit root_path
      click_link("Sign up") 
      fill_in("Name", :with => "Amy Poehler")
      fill_in("Email", :with => "amy@gmail.com")
      fill_in("Password", :with => "foobar")
      fill_in("Password confirmation", :with => "foobar")
      click_button "Sign Up"
      
      @user = User.find_by(:email => "amy@gmail.com")
      expect(page.current_path).to eq(user_path(@user))
    end

    scenario 'user receives error message if password conf. doesn\'t match password' do 
      visit root_path
      click_link("Sign up") 
      fill_in("Name", :with => "Amy Poehler")
      fill_in("Email", :with => "amy@gmail.com")
      fill_in("Password", :with => "foobar")
      fill_in("Password confirmation", :with => "fizzbuzz")
      click_button "Sign Up"
      expect(page.body).to have_content("Password confirmation doesn't match Password")
    end

    scenario 'user receives error message if email is invalid when signing up' do 
      visit root_path
      click_link("Sign up") 
      fill_in("Name", :with => "Amy Poehler")
      fill_in("Email", :with => "amygmail.com")
      fill_in("Password", :with => "foobar")
      fill_in("Password confirmation", :with => "foobar")
      click_button "Sign Up"

      expect(page.body).to have_content("Email is invalid")
    end

    scenario 'user receives error message if email is invalid when signing up' do 
      visit root_path
      click_link("Sign up") 
      fill_in("Email", :with => "amygmail.com")
      fill_in("Password", :with => "foobar")
      fill_in("Password confirmation", :with => "foobar")
      click_button "Sign Up"
      expect(page.body).to have_content("Name can't be blank")
    end
  end

  describe '#logging in' do 

    before(:each) do
      @user = create(:user)
    end

    scenario 'registered user can log in' do
      visit root_path
      click_link("Log In") 
      fill_in("Email", :with => @user.email)
      fill_in("Password", :with => @user.password)
      click_button "Log In"

      expect(page.current_path).to eq(user_path(@user))

    end

    scenario 'logged in user can log out' do 
      visit root_path
      click_link("Log In") 
      fill_in("Email", :with => @user.email)
      fill_in("Password", :with => @user.password)
      click_button "Log In"
      click_link "Log Out" 
      expect(page.current_path).to eq("/")
    end

    scenario 'users without an account cannot log in' do 
      visit root_path
      click_link("Log In") 
      fill_in("Email", :with => "jeremy.sklarsky@gmail.com")
      fill_in("Password", :with => "password")
      click_button "Log In"
      expect(page.body).to have_content("User name or password is not valid.")
    end

    scenario 'users cannot log in with wrong password' do 
      visit root_path
      click_link("Log In") 
      fill_in("Email", :with => @user.email)
      fill_in("Password", :with => "awrongpassword")
      click_button "Log In"
      expect(page.body).to have_content("User name or password is not valid.")
    end
  end




end
