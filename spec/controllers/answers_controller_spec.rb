require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:question) { question = create(:question) }

  describe 'GET #new' do
    before  { get :new, params: { question_id: question.id } }

    it 'renders new' do
      expect(response).to render_template(:new)
    end

    it 'assigns new answer' do
      expect(assigns(:answer)).to be_a_new(Answer)
    end
  end

  describe 'POST #create' do
    context 'valid answer' do
      let(:answer_params) { { answer: attributes_for(:answer), question_id: question } }
      it 'creates answer in database' do
        expect do
          post :create, params: answer_params
        end.to change(question.answers, :count).by(1)
      end

      it 'redirects to question page' do
        post :create, params: answer_params
        expect(response).to redirect_to(question)
      end
    end

    context 'invalid answer' do
      let(:answer_params) { { answer: attributes_for(:invalid_answer), question_id: question } }
      it 'does not create answer in database' do
        expect do
          post :create, params: answer_params
        end.not_to change(Answer, :count)
      end

      it 'renders new' do
        post :create, params: answer_params
        expect(response).to render_template(:new)
      end
    end
  end
end