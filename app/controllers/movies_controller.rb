class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    redirect = false
    if params[:ratings] != nil
        @ratings_to_show = params[:ratings]
        session[:ratings] = params[:ratings]
    elsif params[:ratings] == nil && params[:commit] == "Refresh"
        @ratings_to_show = nil
        session[:ratings] = nil
    elsif session[:ratings] != nil
        redirect = true
        @ratings_to_show = session[:ratings]
    else
        @ratings_to_show = Hash.new
        @all_ratings.each do |r|
            @ratings_to_show[r] = 1
        end
    end
    
    if params[:sort] != nil
        @sort = params[:sort]
        session[:sort] = params[:sort]
    elsif session[:sort] != nil
        redirect = true
        @sort = session[:sort]
    else
        @sort = nil
    end
    
    if @sort == 'title'
      @title_header = 'hilite'
    elsif @sort == 'release_date'
      @release_date_header = 'hilite'
    end

      
    if redirect
        flash.keep
        redirect_to movies_path("ratings" => @ratings_to_show,"sort"=>@sort)
    end
      
    if @sort and @ratings_to_show
      @movies = Movie.where(:rating => @ratings_to_show.keys).order(@sort)
    elsif @ratings_to_show
      @movies = Movie.where(:rating => @ratings_to_show.keys)
    elsif @sort
      @movies = Movie.all.order(@sort)
    else
      @movies = Movie.all
    end  
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
