class DashboardController < ApplicationController
  
  def index
    extended
    render :extended
  end
  
  def extended
    @page_title = 'Dashboard'
    @sites = Site.all :include => { :watches => :status }
  end
  
  def compact
    @page_title = 'Dashboard'
    unless params[:site].nil? or params[:site].blank?
      @page_title = Site.find(params[:site]).name + ' ' + @page_title
      @sites = [Site.find(params[:site], :include => { :watches => :status })]
    else
      @sites = Site.all :include => { :watches => :status }
    end
  end

end
