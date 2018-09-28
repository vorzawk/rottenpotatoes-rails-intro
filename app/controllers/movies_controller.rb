class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # The goal here is to execute the database query and provide the Movies
    # ActiveRecord to the view.
    # Initialize the @movies variable with all the movies.
    @movies = Movie.all
    @all_ratings = Movie.distinct.pluck("rating")
    # All boxes must be checked intially and user choice must not be forgotten 
    # while displaying the movie list again. This is done by using the checked
    # argument in the check_box_tag function in the view.
    @checked = {}
    @all_ratings.each {|rating|
        @checked[rating] = true
    }
    # Overwrite the @movies variable with the appropriate values depending on the 
    # values in params
    if params.has_key?(:sort_by) 
       if params[:sort_by] == 'movie_title'
        @movies = Movie.order("title")
       elsif params[:sort_by] == 'release_date'
        @movies = Movie.order("release_date")
       end
    end
    if params.has_key?(:ratings)
        ratings = params[:ratings].keys
        @movies = Movie.where(rating: ratings)
        @checked = params[:ratings]
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

end
