class ArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    articles = Article.all.includes(:user).order(created_at: :desc)
    render json: articles, each_serializer: ArticleListSerializer
  end

  def show
    # initial value of page views is set to 0
    session[:page_views] ||= 0
    # for every request to /articles/:id, the value will increase by 1
    session[:page_views] += 1

    # if the viewer has viewd 3 or fewer pages, render a JSON response w/ article data
    if session[:page_views] <= 3
      article = Article.find(params[:id])
      render json: article
    # if the user has viewed more than 3 pages, render a JSON response w/ error message and 401 status code
    else
      render json: { error: "Maximum pageview limit reached" }, status: :unauthorized
    end
  end

  private

  def record_not_found
    render json: { error: "Article not found" }, status: :not_found
  end

end
