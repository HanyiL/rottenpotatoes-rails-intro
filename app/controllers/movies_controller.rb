class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @ratings_to_show = params[:ratings]
    if @ratings_to_show == nil
        if params[:sort] != nil && session[:ratings] != nil
            @ratings_to_show = session[:ratings]
        elsif params[:sort] == nil && session[:sort] != nil && params[:ratings] == nil && session[:ratings] !=nil
            @ratings_to_show = session[:ratings]
            @sort = session[:sort]
        else
            @ratings_to_show = {}
        end
    end

    if @ratings_to_show == {}
      @ratings_to_show = Hash[@all_ratings.map {|rating| [rating,'1']}]
    end
      
    @sort = params[:sort]
    if @sort == nil
        @sort = session[:sort]
    end
    if @sort == 'title'
      @title_header = 'hilite'
    elsif @sort == 'release_date'
      @release_date_header = 'hilite'
    end

    if params[:sort] != session[:sort]
      session[:sort] = @sort
      session[:ratings] = @ratings_to_show
      redirect_to movies_path("ratings" => @ratings_to_show,"sort"=>@sort)
    end
    @movies = Movie.where(rating: @ratings_to_show.keys).order(@sort)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
