class CommentsController < ApplicationController
  include ActionView::Helpers::TextHelper
  # GET /events
  # GET /events.json

  def create
    logger.info('Create Comment')
    @comment = Comment.new(comment_params)
    @comment.body = comment_params[:body]
    @rsvp_hash_key = params[:comment][:rsvp_hash_key]

    respond_to do |format|
      if @comment.save
        format.html { redirect_to event_url(@comment.commentable, rsvp: @rsvp_hash_key), notice: 'Comments were successfully updated.' }
        format.json { render :show, status: :ok, location: @comment.commentable }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def delete
    comment = Comment.find(params[:id].to_i)
    unless current_user == comment.user 
      render json: {result: false}
      return
    end
    comment.delete
    render json: {result: true}
  end

  def update 
    @comment = Comment.find(params[:comment][:id].to_i)
    @comment.body = params[:comment][:body]
    @rsvp_hash_key = params[:comment][:rsvp_hash_key]

    respond_to do |format|
      if @comment.save
        format.html { redirect_to event_url(@comment.commentable, rsvp: @rsvp_hash_key), notice: 'Comments were successfully updated.' }
        format.json { render :show, status: :ok, location: @comment.commentable }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:body, :commentable_id, :commentable_type, :user_id, :rsvp_hash_key)
  end

end  


