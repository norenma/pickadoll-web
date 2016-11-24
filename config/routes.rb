Rails.application.routes.draw do
  resources :users

  resources :questionnaires do
    resources :categories do
      resources :questions do
        resources :media_files
      end
    end

    resources :rights
  end

  resources :answers

  resources :response_options

  # allowing for ajax posts to update the order
  # quite a long one innit
  post 'questionnaires/:id/categories/:id/updateOrder', to: 'categories#update_order'
  get 'questionnaires/:id/categories/:id/updateOrder', to: 'categories#update_order'

  # Route for the question media upload
  post 'questions/upload_image'
  post 'questions/upload_audio'
  post 'questions/remove_image'
  post 'questions/remove_audio'

  # Route for the category media upload
  post 'categories/upload_image'
  post 'categories/upload_audio'
  post 'categories/remove_image'
  post 'categories/remove_audio'

  # Routes to edit the result-categories
  post 'result_categories/new'
  get 'result_categories/list/:questionnaire', to: 'result_categories#list'
  delete 'result_categories/deleteItem/:id', to: 'result_categories#remove'


  # Route for cloning questionnaire
  post 'questionnaires/:id/clone', to: 'questionnaires#clone', as: 'clone_questionnaire'

  post 'questionnaires/:id/addNewCategory', to: 'questionnaires#add_new_category'
  post 'questionnaires/:id/updateCategoryOrder', to: 'questionnaires#update_category_order'
  post 'questionnaires/:id/categories/:cat_id/add', to: 'questionnaires#add_existing_category'
  post 'questionnaires/:id/categories/:cat_id/questions/:quest_id/add', to: 'questionnaires#add_existing_question'


  # set response option for all questions in a questionnaire
  post 'questionnaires/:id/setResponseOptionForAllQuestions', to: 'questionnaires#set_response_option_for_all_questions'

  # for categories
  get 'categories/list/all', to: 'categories#list'
  post 'questionnaires/:id/categories/:id/addNewQuestionToCategory', to: 'categories#add_new_question_to_category'

  # for questions
  get 'questions/list/all', to: 'questions#list'

  # for response options
  get 'response_options/list/all', to: 'response_options#list'
  get 'response_options/getById/:id', to: 'response_options#by_id'
  get 'response_options/getAudioById/:id', to: 'response_options#audio_by_id'

  # for adding new item to response options set
  post 'response_options/:id/addNewItem', to: 'response_options#add_response_option_item'
  # for deleting an item from a response options set
  delete 'response_options/deleteItem/:id', to: 'response_options#delete_response_option_item'

  post 'response_options/edit', to: 'response_options#edit'

  # for rights
  # get 'questionnaires/:id/rights/new', to: 'rights#new', as: 'new_right'

  root to: 'sessions#login'
  get 'sessions/login'
  post 'sessions/login_attempt'
  get 'sessions/home'
  get 'sessions/profile'
  get 'sessions/setting'
  get 'sessions/logout'

  # for generating a CSV file
  post 'answers/generate_csv', to: 'answers#generate_csv'

  # To delete questions and categories
  delete 'questions/:id', to: 'questions#destroy'
  delete 'categories/:id', to: 'categories#destroy'

  # Specificiera API-delen, den som primärt snackar med appen.
  namespace :api do
    post 'users/login' => 'users#login'
    get 'users/login' => 'users#login'
    resources :questionnaires, :users, defaults: { format: 'json' }

    post 'postResultsFromApp/', to: 'questionnaires#post_results_from_app'

    get 'questionnaires/fetch/:id', to: 'questionnaires#fetch'
    get 'questionnaires/fetchAllForUser/:id', to: 'questionnaires#fetch_all_for_user'
  end
end
