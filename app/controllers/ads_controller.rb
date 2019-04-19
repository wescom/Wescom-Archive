class AdsController < ApplicationController
    before_action :require_user

    def index
      if params[:search_query]
        begin
          @ads = Ad.search do
            paginate(:page => params[:page], :per_page => 16)
            fulltext params[:search_query]
            with(:proof_date).greater_than_or_equal_to(Date.strptime(params[:date_from_select], "%m/%d/%Y")) if params[:date_from_select].present?
            with(:proof_date).less_than_or_equal_to(Date.strptime(params[:date_to_select], "%m/%d/%Y")) if params[:date_to_select].present?
            order_by :proof_date, :desc
        end
        rescue Errno::ECONNREFUSED
          render :text => "Search Server Down\n\n\n It will be back online shortly"
        end
      end

      increase_search_count
      @total_ads_count = Ad.all.count
    end

    def show
      @ad = Ad.find(params[:id])
      @logs = @ad.logs.all.order('created_at DESC')
      @last_updated = @logs.first
      render :layout => "plain"
    end
    
    def new
      @ad = Ad.new
    end

    def create
      if params[:cancel_button]
          redirect_to ads_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select])
      else
          @ad = Ad.new(ad_params)
          if @ad.save
            flash_message :notice, "Ad Created"
            redirect_to ads_path
          else
            flash_message :error, "Ad Creation Failed"
            render :action => :new
          end
      end
    end

    def destroy
      @ad = Ad.find(params[:id])
      if @ad.destroy
          flash_message :notice, "Ad Killed!"
          redirect_to ads_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select])
      else
          flash_message :notice, "Ad Deletion Failed"
          redirect_to ads_path(:date_from_select=>params[:date_from_select], :date_to_select=>params[:date_to_select])
      end
    end

    private
      def ad_params
        params.require(:ad).permit(:ad_name,:proof_date,:image)
      end
end
