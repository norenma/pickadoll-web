class MediaFilesController < ApplicationController
  def create
    render plain: params[:question].inspect
  end
end
