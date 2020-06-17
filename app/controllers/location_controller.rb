class LocationController < ApplicationController
  def index

  end

  def tags
    @location_tags = LocationTag.where(" voided = 0 ").order('name')
  end

  def new
    @location = Location.new
    @tags = LocationTag.all.each_slice(4).to_a
    @action = "/location/new"
    if request.post?
      l = Location.create(
          name: params[:name],
          code: params[:code],
          description: params[:description]
      )

      (params[:tags] || []).each do |tag|
        LocationTagMap.create(location_id: l.id, location_tag_id: tag)
      end
      redirect_to "/location/index" and return
    end
  end

  def edit
    @action = "/location/edit"
    @location = Location.find(params[:location_id])
    @tags = LocationTag.all.each_slice(4).to_a
    @seleted_tags = LocationTagMap.where(location_id: @location.id).map(&:location_tag_id)

    if request.post?
      @location.name = params[:name]
      @location.code = params[:code]
      @location.description = params[:description]
      @location.save

      LocationTagMap.where(location_id: @location.id).delete_all
      (params[:tags] || []).each do |tag|
        LocationTagMap.create(location_id: @location.id, location_tag_id: tag)
      end
      redirect_to "/location/index" and return
    end
  end

  def view
    @location = Location.find(params[:location_id])
    @tags = LocationTagMap.where(location_id: @location.id).collect{|l| LocationTag.find(l.location_tag_id).name}
  end

  def delete
    tag_maps = LocationTagMap.find_by_sql("SELECT * FROM location_tag_map WHERE location_tag_id = #{params[:location_id]}")
    if tag_maps.blank?
      loc = Location.find(params[:location_id])
      if (loc.destroy rescue false)
        flash[:error] = "Successfully deleted location type"
      else
        flash[:error] = "Location already in use by some items"
      end
    else
      flash[:error] = "Location already in use by #{tag_maps.count} tag items"
    end

    redirect_to '/location/index'
  end

  def new_tag
    @location_tag = LocationTag.new
    @action = "/location/new_tag"
    if request.post?
      LocationTag.create(name: params[:name], description: params[:description])
      redirect_to "/location/tags" and return
    end
  end

  def edit_tag
    @action = "/location/edit_tag"
    @location_tag = LocationTag.find(params[:tag_id])
    if request.post?
      @location_tag.name = params[:name]
      @location_tag.description = params[:description]
      @location_tag.save
      redirect_to "/location/tags" and return
    end
  end

  def view_tag
    @location_tag = LocationTag.find(params[:tag_id])
  end

  def delete_tag
    tag_maps = LocationTagMap.find_by_sql("SELECT * FROM location_tag_map WHERE location_tag_id = #{params[:tag_id]}")
    if tag_maps.blank?
      tag = LocationTag.find(params[:tag_id])
      tag.destroy
      flash[:error] = "Successfully deleted location type"
    else
      flash[:error] = "Location type already in use by #{tag_maps.count} items"
    end

    redirect_to '/location/tags'
  end

  def ajax_locations

    search_val = params[:search][:value] rescue nil
    search_val = '_' if search_val.blank?
    tag_filter = ''

    if params[:tag_id].present?
      location_ids = LocationTagMap.find_by_sql(" SELECT m.location_id FROM location_tag_map m WHERE m.location_tag_id = #{params[:tag_id]}").map(&:location_id) + [-1]
      tag_filter = " AND location.location_id IN (#{location_ids.join(', ')}) "
    end

    data = Location.order(' location.name ')
    data = data.where(" ( location.name LIKE '%#{search_val}%' #{tag_filter} OR  location.code LIKE '%#{search_val}%' #{tag_filter} ) ")
    total = data.select(" count(*) c ")[0]['c'] rescue 0
    page = (params[:start].to_i / params[:length].to_i) + 1

    data = data.select(" location.* ")
    data = data.page(page).per_page(params[:length].to_i)

    @records = []
    data.each do |p|
      types = (LocationTag.find_by_sql("SELECT name FROM location_tag WHERE location_tag_id IN
                (SELECT location_tag_id FROM location_tag_map WHERE location_id = #{p.location_id})")).map(&:name)
      row = [p.name, p.code, types.join(', '), (Location.find(p.parent_location).name rescue nil),  p.location_id]
      @records << row
    end

    render :text => {
        "draw" => params[:draw].to_i,
        "recordsTotal" => total,
        "recordsFiltered" => total,
        "data" => @records}.to_json and return
  end

  def nationalities(cizenships=false)
    tag_id = LocationTag.where(name: "Country").first.id;
    locations = Location.find_by_sql(
        "SELECT l.name, l.country FROM location l INNER JOIN location_tag_map m ON l.location_id = m.location_id  WHERE m.location_tag_id = #{tag_id} ")

    if cizenships == true
      locations.map(&:country)
    else
      locations.map(&:name)
    end

    render text: ([""] + locations.sort).to_json
  end

  def countries
    tag_id = LocationTag.where(name: "Country").first.id
    locations = Location.find_by_sql(
        "SELECT l.name FROM location l INNER JOIN location_tag_map m ON l.location_id = m.location_id  WHERE m.location_tag_id = #{tag_id} ").collect{|s| s.name.force_encoding('utf-8').encode}

    render text: ([""] + locations.sort).to_json
  end

  def districts
    tag_id = LocationTag.where(name: "District").first.id
    locations = Location.find_by_sql(
        "SELECT l.name FROM location l INNER JOIN location_tag_map m ON l.location_id = m.location_id  WHERE m.location_tag_id = #{tag_id} ").collect{|s| s.name.force_encoding('utf-8').encode}

    render text: ([""] + locations.sort).to_json
  end

  def tas
    district = params[:parent]
    district_tag_id = LocationTag.where(name: "District").first.id
    tag_id = LocationTag.where(name: "Traditional Authority").first.id

    district_id = Location.find_by_sql(
        "SELECT l.location_id FROM location l
          INNER JOIN location_tag_map m ON l.location_id = m.location_id
          WHERE m.location_tag_id = #{district_tag_id} AND l.name = '#{district}' "
    ).last.location_id

    locations = Location.find_by_sql(
        "SELECT l.name FROM location l
          INNER JOIN location_tag_map m ON l.location_id = m.location_id
          WHERE m.location_tag_id = #{tag_id} AND l.parent_location = #{district_id}").collect{|s| s.name.force_encoding('utf-8').encode}

    render text: ([""] + locations.sort).to_json
  end

  def villages
    district = params[:district]
    ta = params[:ta]

    district_tag_id = LocationTag.where(name: "District").first.id
    tag_id = LocationTag.where(name: "Village").first.id
    ta_tag_id = LocationTag.where(name: "Traditional Authority").first.id

    district_id = Location.find_by_sql(
        "SELECT l.location_id FROM location l
          INNER JOIN location_tag_map m ON l.location_id = m.location_id
          WHERE m.location_tag_id = #{district_tag_id} AND l.name = '#{district}' "
    ).last.location_id

    ta_id = Location.find_by_sql(
        "SELECT l.location_id FROM location l
          INNER JOIN location_tag_map m ON l.location_id = m.location_id
          WHERE m.location_tag_id = #{ta_tag_id} AND l.name = \"#{ta}\" AND l.parent_location = #{district_id} "
    ).last.location_id

    locations = Location.find_by_sql(
        "SELECT l.name FROM location l
          INNER JOIN location_tag_map m ON l.location_id = m.location_id
          WHERE m.location_tag_id = #{tag_id} AND l.parent_location = #{ta_id}").collect{|s| s.name.force_encoding('utf-8').encode}

    render text: ([""] + locations.sort).to_json
  end

  def health_facilities
     district = params[:district]
     district_tag_id = LocationTag.where(name: "District").first.id

     district_id = Location.find_by_sql(
         "SELECT l.location_id FROM location l
           INNER JOIN location_tag_map m ON l.location_id = m.location_id
           WHERE m.location_tag_id = #{district_tag_id} AND l.name = '#{district}' "
     ).last.location_id

     health_facility_location_tag = LocationTag.where(name: 'Health Facility').first
     
     locations = Location.find_by_sql(
      "SELECT l.name FROM location l
        INNER JOIN location_tag_map m ON l.location_id = m.location_id
        WHERE m.location_tag_id = #{health_facility_location_tag.id} AND l.parent_location = #{ district_id}").collect{|s| s.name.force_encoding('utf-8').encode}  
        
      render text: ([""] + locations.sort).to_json 
  end

  def set_current
    if params[:district]
      hash = {}
      case params[:type]
      when "DRO"
        hash = {
            'type' => "DRO",
            'district' => params[:district]
        }
      when "Village"
        hash = {
            'type' => "Village",
            'district' => params[:district],
            'ta'       => params[:ta],
            'village'  => params[:village]
        }
      when "Health Facility"
        hash = {
            'type' => "Health Facility",
            'district' => params[:district],
            'health_facility' => params[:health_facility]
        }
      else
        "Error: capacity has an invalid value (#{params[:type]})"
      end

      File.open("#{Rails.root}/public/current.json", "w"){|f| f.write(hash.to_json)}

      render :text => "OK"
    else
      @cur_location = JSON.parse(File.read("#{Rails.root}/public/current.json")) rescue {}
      if @cur_location.blank?
        @header = "Set Registration Village"
      else
        @header = "Confirm Registration Village"
      end
    end
  end

end
