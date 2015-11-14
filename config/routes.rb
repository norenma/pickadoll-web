Rails.application.routes.draw do
  resources :users

  resources :questionnaires do
    resources :categories do
      resources :questions do
        resources :media_files
      end
    end
  end

  resources :answers

  resources :response_options

  #allowing for ajax posts to update the order
  #quite a long one innit
  post 'questionnaires/:id/categories/:id/updateOrder', to: 'categories#updateOrder'
  get 'questionnaires/:id/categories/:id/updateOrder', to: 'categories#updateOrder'

  #Route for the question media upload
  post 'questions/uploadImage'
  post 'questions/uploadAudio'

  #Route for the category media upload
  post 'categories/uploadImage'
  post 'categories/uploadAudio'

  #Route for cloning questionnaire
  post 'questionnaires/:id/clone', to: 'questionnaires#clone', as: 'clone_questionnaire'

  post 'questionnaires/:id/addNewCategory', to: 'questionnaires#addNewCategory'
  post 'questionnaires/:id/updateCategoryOrder', to: 'questionnaires#updateCategoryOrder'

  #set response option for all questions in a questionnaire
  post 'questionnaires/:id/setResponseOptionForAllQuestions', to: 'questionnaires#setResponseOptionForAllQuestions'


  #for categories
  post 'questionnaires/:id/categories/:id/addNewQuestionToCategory', to: 'categories#addNewQuestionToCategory'

  #for response options
  get 'response_options/list/all', to: 'response_options#list'
  get 'response_options/getById/:id', to: 'response_options#getById'
  get 'response_options/getAudioById/:id', to: 'response_options#getAudioById'

  #for adding new item to response options set
  post 'response_options/:id/addNewItem', to: 'response_options#addResponseOptionItem'
  #for deleting an item from a response options set
  delete 'response_options/deleteItem/:id', to: 'response_options#deleteResponseOptionItem'

  post 'response_options/edit', to: 'response_options#edit'

  root :to => "sessions#login"
  get 'sessions/login'
  post 'sessions/login_attempt'
  get 'sessions/home'
  get 'sessions/profile'
  get 'sessions/setting'
  get 'sessions/logout'


  #for generating a CSV file
  post 'answers/generateCSV', to: 'answers#generateCSV'

  #To delete questions and categories
  delete 'questions/:id', to: 'questions#destroy'
  delete 'categories/:id', to: 'categories#destroy'

  #Specificiera API-delen, den som primärt snackar med appen.
  namespace :api do
    post "users/login" => "users#login"
    get "users/login" => "users#login"
    resources :questionnaires, :users, :defaults => { :format => 'json' }

    post "postResultsFromApp/", to: 'questionnaires#postResultsFromApp'

    get "questionnaires/fetch/:id", to: 'questionnaires#fetch'
    get "questionnaires/fetchAllForUser/:id", to: 'questionnaires#fetchAllForUser'
  end
end
