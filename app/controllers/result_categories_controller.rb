class ResultCategoriesController < ApplicationController
    def new
        @cat = ResultCategory.new
        @cat.name = params[:name]
        @cat.questionnaire_id = params[:questionnaire_id]
        @cat.save
        redirect_to questionnaires_path
    end
    def index
    end
    def list
        @questionnaire_id = params[:questionnaire]
        @result = ResultCategory.where(questionnaire_id: @questionnaire_id)
        puts "hej"
        puts @result
        render json: @result
    end

    def remove
        id = params[:id]

        if ResultCategory.destroy(id)
            render json: { 'status' => 'success', 'item_id' => id }
        else
           render json: { 'status' => 'fail', 'item_id' => id }
        end
    end
end
