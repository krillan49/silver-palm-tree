class PodcastsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]
  before_action :set_podcast!, only: %i[show edit update destroy]
  before_action :only_author_access, only: %i[edit update destroy]

  def index
    podcasts = get_podcasts.includes(:user)
    render partial: "podcasts_list", locals: { podcasts: podcasts }
  end

  def show
  end

  def new
    @podcast = Podcast.new
  end

  def create
    @podcast = current_user.podcasts.build(podcast_params)

    respond_to do |format|
      if @podcast.save
        flash[:notice] = "Your podcast was successfully created."
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("podcast_frame", partial: "podcasts/podcast", locals: { podcast: @podcast }),
            turbo_stream.append("flash", partial: "shared/flash", locals: { message: notice })
          ]
        end
        format.html { redirect_to @podcast, notice: notice }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form", partial: "podcasts/form", locals: { podcast: @podcast }),
            turbo_stream.replace("alert", partial: "shared/errors", locals: { resource: @podcast })
          ]
        end
        format.html { render :new }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @podcast.update(podcast_params)
        flash[:notice] = "Your podcast was successfully updated."
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("podcast_frame", partial: "podcasts/podcast", locals: { podcast: @podcast }),
            turbo_stream.append("flash", partial: "shared/flash", locals: { message: notice })
          ]
        end
        format.html { redirect_to @podcast, notice: "Your podcast was successfully updated." }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form", partial: "podcasts/form", locals: { podcast: @podcast }),
            turbo_stream.replace("alert", partial: "shared/errors", locals: { resource: @podcast })
          ]
        end
        format.html { render :new }
      end
    end
  end

  def destroy
    if @podcast.destroy
      redirect_to root_path
    else
      flash[:error] = @podcast.errors.full_messages
      render :show, locals: { podcast: @podcast }
    end
  end

  private

  def get_podcasts
    Podcast.all unless current_user

    case params[:filter]
    when "my_podcasts";   current_user.podcasts
    when "subscriptions"; current_user.subscribed_podcasts
    else;                 Podcast.all
    end
  end

  def set_podcast!
    @podcast = Podcast.find_by(id: params[:id])
  end

  def only_author_access
    unless @podcast.authored_by?(current_user)
      redirect_back fallback_location: root_path
    end
  end

  def podcast_params
    params.require(:podcast).permit(:title, :description, :photo, :audio)
  end
end
