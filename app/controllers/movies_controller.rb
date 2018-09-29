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
    @all_ratings = Movie.distinct.pluck("rating")
    # The requirement is that all boxes must be checked intially, and also the 
    # previous user choice must not be forgotten.
    # This is done by using the @checked argument in the check_box_tag function in
    # the view.
    @checked = {}
    # All checkboxes must be set initially
    @all_ratings.each {|rating|
        @checked[rating] = true
    }

    if params.has_key?(:sort_by)
        session[:sort_by] = params[:sort_by]
    end

    if params.has_key?(:ratings)
        # Remember the previous user setting
        @checked = params[:ratings]
        session[:ratings] = params[:ratings]
    end

    if not params.has_key?(:sort_by) or not params.has_key?(:ratings) 
        if not session[:sort_by]
            session[:sort_by] = "title"
        end
        if not session[:ratings]
            session[:ratings] = @checked
        end
        # Redirect with all the required parameters so that RESTfulness is preserved.
        redirect_to :sort_by => session[:sort_by], :ratings => session[:ratings]
        return
    else
    end
    # The URI is RESTful, so only the params hash is sufficient
    # to execute the database query.
    ratings = params[:ratings].keys
    @movies = Movie.order(params[:sort_by]).where(rating: ratings)
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
