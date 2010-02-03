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
      # lets you get watch status for multiple sites by passing ?site=1,2,3
      @page_title = Site.find(params[:site].split(',')).collect { |site| site.name }.join(', ') + ' ' + @page_title
      @sites = Site.find(params[:site].split(','), :include => { :watches => :status })
    else
      @sites = Site.all :include => { :watches => :status }
    end
  end

end
