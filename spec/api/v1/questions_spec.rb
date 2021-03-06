require 'rails_helper'

describe 'Questions API' do
  describe 'GET #index' do
    let!(:collection) { FactoryGirl.create_list(:question, 3) }
    let(:http_method) { :get }
    let(:path) { '/api/v1/questions' }
    attributes = %w(id title body created_at updated_at)
    it_behaves_like 'API authenticable'
    it_behaves_like 'API collection', attributes
  end

  describe 'GET #show' do
    let(:question) { create :question }

    context 'when user is not authenticated' do
      it 'return status 401 if there is no access token' do
        get "/api/v1/questions/#{question.id}", format: :json
        expect(response.status).to eq 401
      end

      it 'return status 401 if there is invalid access token' do
        get "/api/v1/questions/#{question.id}", params: { format: :json, access_token: '12345' }
        expect(response.status).to eq 401
      end
    end

    context 'when user authenticated' do
      let!(:access_token) { create :access_token }
      let!(:comments) { create_list(:comment, 2) }
      let!(:attachments) { create_list(:attachment, 2) }

      before do
        question.comments << comments
        question.attachments << attachments
        get "/api/v1/questions/#{question.id}", params: { format: :json, access_token: access_token.token }
      end

      it 'returns status 200' do
        expect(response.status).to eq 200
      end

      %w(id title body created_at updated_at).each do |attr|
        it "contains #{attr} in question" do
          expect(response.body)
            .to be_json_eql(question.send(attr.to_sym).to_json)
            .at_path("question/#{attr}")
        end
      end

      context 'comments' do
        %w(id content created_at updated_at).each do |attr|
          it "contains #{attr} in comment" do
            comment = comments.first
            expect(response.body)
              .to be_json_eql(comment.send(attr.to_sym).to_json)
              .at_path("question/comments/0/#{attr}")
          end
        end
      end

      context 'attachments' do
        it "contains url for each question attachment" do
          attachment = attachments.last
          expect(response.body)
            .to be_json_eql(attachment.file.url.to_json)
            .at_path("question/attachments/0/url")
        end
      end
    end
  end

  describe 'POST #create' do
    let(:http_method) { :get }
    let(:path) { '/api/v1/questions' }
    it_behaves_like 'API authenticable'

    context 'when user is authenticated' do
      let!(:user) { create :user }
      let!(:access_token) { create :access_token, resource_owner_id: user.id }
      context 'valid params' do
        it 'returns status 201' do
          post "/api/v1/questions", params: { question: attributes_for(:question), format: :json, access_token: access_token.token }
          expect(response.status).to eq 201
        end

        it 'returns success' do
          post '/api/v1/questions', params: { question: attributes_for(:question), format: :json, access_token: access_token.token }
          expect(response).to be_success
        end

        it 'return question json with new body' do
          new_body = "test body"
          post '/api/v1/questions', params: { question: attributes_for(:question, body: new_body), format: :json, access_token: access_token.token }
          expect(response.body).to be_json_eql(new_body.to_json).at_path("question/body")
        end

        it 'return question json with new title' do
          new_title = "test title"
          post '/api/v1/questions', params: { question: attributes_for(:question, title: new_title), format: :json, access_token: access_token.token }
          puts response.body
          expect(response.body).to be_json_eql(new_title.to_json).at_path("question/title")
        end

        it 'saves questions to database' do
          expect { post "/api/v1/questions", params: { question: attributes_for(:question), format: :json, access_token: access_token.token } }
            .to change(user.questions, :count).by(1)
        end
      end

      context 'invalid params' do
        it 'returns status 422' do
          post "/api/v1/questions", params: { question: attributes_for(:invalid_question), format: :json, access_token: access_token.token }
          expect(response.status).to eq 422
        end

        it 'saves questions to database' do
          expect { post "/api/v1/questions", params: { question: attributes_for(:invalid_question), format: :json, access_token: access_token.token } }
            .not_to change(Question, :count)
        end
      end
    end
  end
end
