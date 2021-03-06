require_relative '../../../spec/acceptance/acceptance_helper'

feature 'Create question', '
  It order to get answer from community
  As an authenticated user
  I want to be able to ask questions
' do

  given(:user) { create(:user) }

  scenario 'Authenticated user creates question' do
    sign_in(user)

    visit questions_path
    click_on 'New question', match: :first
    fill_in 'Title', with: 'Test question'
    fill_in 'Body', with: 'test text'
    click_on 'Create'

    expect(page).to have_content 'Question was successfully created.'
  end

  scenario 'Non-authenticated user ties to create question' do
    visit questions_path
    click_on 'New question', match: :first

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end

  scenario 'Authenticated user submit invalid question' do
    sign_in(user)
    visit questions_path
    click_on 'New question', match: :first
    click_on 'Create'

    expect(current_path).to eq questions_path
    expect(page).to have_content "Title can't be blank"
    expect(page).to have_content "Body can't be blank"
    expect(page).to have_content "Title is too short (minimum is 5 characters)"
  end
end
