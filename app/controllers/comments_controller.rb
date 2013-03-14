class CommentsController < ApplicationController
  before_filter :authenticate_user!
  include ApplicationHelper

  def create
    return unless params[:comment][:body]
    @comment = Comment.new(params[:comment])
    @comment.user_id = current_user.id
    result = @comment.save
    render :json => @comment, :root => false
  end

  def index
    @comments = Comment.all
    render :json => @comments, :root => false
  end

  def show
    @comment = Comment.find(params[:id])
    render :json => @comment, :root => false
  end

  def destroy
    return if anonymous_user
    @comment = Comment.find(params[:id])
    if @comment.user_id == current_user.id
      render :json => {:success => @comment.destroy}
    end
  end

  def update
    # TODO: some kinda error here, serializer not hooked up properly.
    return if anonymous_user
    @comment = Comment.find(params[:id])
    if @comment.user_id == current_user.id
      if @comment.update_attributes(params[:comment])
        render :json => @comment, :root => false
      end

    end
  end

  def editor
    return if anonymous_user
    @comment = Comment.find(params[:id])
    if @comment.user_id == current_user.id
      render "comments/edit_in_place", :layout => nil
    end
  end
end