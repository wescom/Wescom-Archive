class AdsController < ApplicationController
    before_action :require_user

    def index
      if params[:search_query]
        begin
          @ads = Ad.search do
            paginate(:page => params[:page], :per_page => 16)
            fulltext params[:search_query]
            any_of do
                all_of do
                    with(:startDate).greater_than_or_equal_to(Date.strptime(params[:date_from_select], "%m/%d/%Y")) if params[:date_from_select].present?
                    with(:startDate).less_than_or_equal_to(Date.strptime(params[:date_to_select], "%m/%d/%Y")) if params[:date_to_select].present?
                    # need something true to avoid a failure when no date_to_select or date_from_select
                    with(:proof_date).greater_than_or_equal_to("01/01/2000")
                end
                all_of do
                    with(:stopDate).greater_than_or_equal_to(Date.strptime(params[:date_from_select], "%m/%d/%Y")) if params[:date_from_select].present?
                    with(:stopDate).less_than_or_equal_to(Date.strptime(params[:date_to_select], "%m/%d/%Y")) if params[:date_to_select].present?
                    # need something true to avoid a failure when no date_to_select or date_from_select
                    with(:proof_date).greater_than_or_equal_to("01/01/2000")
                end
            end
            order_by :startDate, :desc
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
