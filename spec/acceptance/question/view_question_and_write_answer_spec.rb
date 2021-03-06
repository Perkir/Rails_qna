require_relative '../../../spec/acceptance/acceptance_helper'

feature 'view question and write answer', '
In order to be a question and existing answer to it
As any user
I want to be able see view question with answer
' do

  given!(:question) { create(:question) }

  scenario 'Any user can view question and answer for him' do
    list = create_list(:answer, 2, question: question)

    visit question_path(question)

    list.each { |answer| expect(page).to have_content(answer.body) }
    expect(page).to have_content(question.title)
    expect(page).to have_content(question.body)
  end
end
