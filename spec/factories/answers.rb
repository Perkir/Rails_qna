FactoryGirl.define do
  sequence :body do |n|
    "MyAswerBody#{n}"
  end

  factory :answer do
    question
    body
    user
  end

  factory :invalid_answer, class: Answer do
    user
    question
    body nil
  end
end
